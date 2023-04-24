# get image tag of latest commit on current branch
head_tag=$(TZ=UTC git log -1 --pretty=format:%cd --date=format-local:"%y%m%d%H%M" HEAD)-$(git rev-parse --short=11 HEAD)
TAG_HEAD=0

error() {
  printf '%s\n' "$1" >&2
  exit 1
}

go_to_namespace() {
  local namespace="$1"
  aws eks update-kubeconfig --name rime-workspaces --region us-west-1 || error "Unable to switch to EKS cluster 'rime-workspaces'"
  kubectl get namespace "${namespace}" || error "Namespace '${namespace}' not found on cluster 'rime-workspaces'"
  kubectl config set-context --current --namespace="${namespace}"
  kubectl -n "${namespace}" get secret rimecreds || error "Registry credential 'rimecreds' not found in namespace '${namespace}' on cluster 'rime-workspaces'"
}

# CONTROL PLANE
controlplane_install_or_upgrade() {
  echo "---------Installing Control Plane-------------"
  local cmd="$1"
  local namespace="$2"
  go_to_namespace $namespace
  pushd rime

  local set_image_options=()
  if [ "${TAG_HEAD}" -ne 0 ]
  then
    set_image_options=(
      --set "rime.images.backendImage.name=robustintelligencehq/rime-backend:${head_tag}"
      --set "rime.images.frontendImage.name=robustintelligencehq/rime-frontend:${head_tag}"
      --set "rime.images.modelTestingImage.name=robustintelligencehq/rime-testing-engine-dev:${head_tag}"
      --set "rime.images.imageBuilderImage.name=robustintelligencehq/rime-image-builder:${head_tag}"
    )
    echo "Overriding image tag to $head_tag"
  fi

  helm -n "${namespace}" dependency update &&
  helm -n "${namespace}" "${cmd}" --debug --values "../../aws/workspaces_cluster/tenants/${namespace}_values/values_${namespace}.yaml" \
  "rime-${namespace}" ./ \
  "${set_image_options[@]}"

  # manually restart all deployments in namespace except for kong and nginx, in order to pull latest docker image.
  kubectl -n "${namespace}" get deployments | grep -v kong | grep -v nginx | grep rime | awk '{print $1}' | xargs kubectl -n "${namespace}" rollout restart deployment
  popd
}

sub_controlplane_install() {
  controlplane_install_or_upgrade install "$1"
}

sub_controlplane_upgrade() {
  controlplane_install_or_upgrade upgrade "$1"
}

sub_controlplane_uninstall() {
  local namespace="$1"
  go_to_namespace $namespace
  helm -n "${namespace}" uninstall "rime-${namespace}"
}

# AGENT
agent_install_or_upgrade() {
  echo "---------Installing Agent-------------"
  echo "Generating operator manifests"
  make gen_operator_manifests

  local cmd="$1"
  local namespace="$2"
  go_to_namespace $namespace
  pushd rime-agent

  local extra_file_cmd=""
  FILE=."../../aws/workspaces_cluster/tenants/${namespace}_values/rime_agent_values_terraform_${namespace}.yaml"
  if test -f "$FILE"; then
      echo "Using custom file in agent install"
      extra_file_cmd="-f $FILE"
  else
      echo "No custom file for agent install specified"
  fi

  set_image_options=()
  if [ "${TAG_HEAD}" -ne 0 ]
  then
    set_image_options=(
      --set "rimeAgent.images.agentImage.name=robustintelligencehq/rime-agent:${head_tag}"
      --set "rimeAgent.images.modelTestJobImage.name=robustintelligencehq/rime-testing-engine-dev:${head_tag}"
    )
    echo "Overriding image tag to $head_tag"
  fi

  helm -n "${namespace}" dependency update &&
  helm -n "${namespace}" "${cmd}" --debug ${extra_file_cmd} \
  -f "../../aws/workspaces_cluster/tenants/${namespace}_values/rime_agent_values_terraform_${namespace}.yaml" \
  "rime-agent-${namespace}" ./ \
  "${set_image_options[@]}"

  # manually restart all deployments in namespace except for kong and nginx, in order to pull latest docker image.
  kubectl -n "${namespace}" get deployments | grep -v kong | grep -v nginx | grep rime-agent | awk '{print $1}' | xargs kubectl -n "${namespace}" rollout restart deployment

  popd
}

sub_agent_install() {
  agent_install_or_upgrade install "$1"
}

sub_agent_upgrade() {
  agent_install_or_upgrade upgrade "$1"
}

sub_agent_uninstall() {
  local namespace="$1"
  go_to_namespace $namespace
  helm -n "${namespace}" uninstall "rime-agent-${namespace}"
}

# RIME (both agent and controlplane)
sub_rime_install() {
  local agent_namespace=${2:-$1}
  sub_controlplane_install "$1"
  sub_agent_install "$agent_namespace"
}

sub_rime_upgrade() {
  local agent_namespace=${2:-$1}
  sub_controlplane_upgrade "$1"
  sub_agent_upgrade "$agent_namespace"
}

sub_rime_uninstall() {
  local agent_namespace=${2:-$1}
  sub_controlplane_uninstall "$1"
  sub_agent_uninstall "$agent_namespace"
}

sub_rime_clean() {
  local namespace="$1"
  go_to_namespace $namespace
  kubectl -n "${namespace}" get pvc |  awk '{print $1}' | grep -v NAME | xargs kubectl -n "${namespace}" delete pvc
}

# Initial Command Parsing
sub_help() {
  local ProgName=$1
  echo "Usage:"
  echo "    ${ProgName} rime <helm_command> <cp-namespace> [<agent-namespace>] [--tag-head]"
  echo "        helm operations on BOTH control plane and agent"
  echo "        (if you do not specify [agent-namespace], agent will be installed in the same namespace as CP)"
  echo "    ${ProgName} agent <helm_command> <namespace>"
  echo "        helm operations on only the agent"
  echo "    ${ProgName} controlplane <helm_command> <namespace>"
  echo "        helm operations on only the control plane"
  echo "    ${ProgName} <helm_command> <helm_command> <namespace> --tag-head"
  echo "        tag all images in workspace to latest commit on current branch "
  echo "        (without this tag all images will default to latest)."
  echo "        Note this this will only work if local head has a green build "
  echo "        on origin master. To use, checkout a commit on origin master "
  echo "        and run this script with --tag-head"
  echo "Helm Commands:"
  echo "    install:     Installs the corresponding Helm chart on cluster 'rime-workspaces' in specified namespace"
  echo "    upgrade:     Upgrades the corresponding Helm chart on cluster 'rime-workspaces' in specified namespace"
  echo "    uninstall:   Uninstalls the corresponding Helm chart on cluster 'rime-workspaces' in specified namespace."
  echo "    clean:       Delete all pvcs in a namespace to clean specified namespace."
  echo "  Note that control plane will be installed as rime-<namespace> and agent as rime-agent-<namespace>"
  echo ""
}

helm_dev() {
  process_flags "$@"
  set -- "${POSITIONAL_ARGS[@]}"

  local ProgName=$(basename $0)
  local subcommand=$1
  local helm_command=$2

  case "${subcommand}" in
    "" | "-h" | "--help" | "help")
      sub_help "${ProgName}"
      exit 0
      ;;
    *)
      shift
      shift
      sub_${subcommand}_${helm_command} $@
      if [ $? = 127 ]; then
          echo "Error: '${subcommand}' '${helm_command}' is not a known subcommand." >&2
          echo "       Run '${ProgName} --help' for a list of known subcommands." >&2
          exit 1
      fi
      ;;
  esac
  # Set the current namespace to the namespace that was just altered before exit.
  kubectl config set-context --current --namespace="$1"
}

process_flags() {
  while [[ $# -gt 0 ]]; do
    case "${1}" in
      --tag-head)
        TAG_HEAD=1
        shift
        ;;
      *)
        POSITIONAL_ARGS+=("${1}") # save positional arg
        shift
        ;;
    esac
  done
}
