error() {
  printf '%s\n' "$1" >&2
  exit 1
}

go_to_namespace() {
  local namespace="$1"
  aws eks update-kubeconfig --name rime-dev --region us-west-2 || error "Unable to switch to EKS cluster 'rime-dev'"
  kubectl get namespace "${namespace}" || error "Namespace '${namespace}' not found on cluster 'rime-dev'"
  kubectl config set-context --current --namespace="${namespace}"
  kubectl -n "${namespace}" get secret rimecreds || error "Registry credential 'rimecreds' not found in namespace '${namespace}' on cluster 'rime-dev'"
}

# CONTROL PLANE
controlplane_install_or_upgrade() {
  echo "---------Installing Control Plane-------------"
  local cmd="$1"
  local namespace="$2"
  go_to_namespace $namespace
  pushd rime
  helm -n "${namespace}" dependency update &&
  helm -n "${namespace}" "${cmd}" --debug --values "../../aws/dev_cluster/dev_cluster_values/values_${namespace}.yaml" "rime-${namespace}" ./

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
  local cmd="$1"
  local namespace="$2"
  go_to_namespace $namespace
  pushd rime-agent

  local extra_file_cmd=""
  FILE=../../aws/dev_cluster/dev_cluster_values/agent/rime_agent_values_${namespace}.yaml
  if test -f "$FILE"; then
      echo "Using custom file in agent install"
      extra_file_cmd="-f $FILE"
  else
      echo "No custom file for agent install specified"
  fi

  helm -n "${namespace}" dependency update &&
  helm -n "${namespace}" "${cmd}" --debug ${extra_file_cmd} \
  -f ../../aws/dev_cluster/dev_cluster_values/agent/rime_agent_values_terraform_${namespace}.yaml \
  rime-agent ./

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
  helm -n "${namespace}" uninstall "rime-agent"
}

# RIME (both agent and controlplane)
sub_rime_install() {
  local agent_namespace=${2:-$1}
  echo $agent_namespace
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
  echo "    ${ProgName} rime <helm_command> <cp-namespace> [<agent-namespace>]"
  echo "        helm operations on BOTH control plane and agent"
  echo "        (if you do not specify [agent-namespace], agent will be installed in the same namespace as CP)"
  echo "    ${ProgName} agent <helm_command> <namespace>"
  echo "        helm operations on only the agent"
  echo "    ${ProgName} controlplane <helm_command> <namespace>"
  echo "        helm operations on only the control plane"
  echo "Helm Commands:"
  echo "    install:     Installs the corresponding Helm chart on cluster 'rime-dev' in specified namespace"
  echo "    upgrade:     Upgrades the corresponding Helm chart on cluster 'rime-dev' in specified namespace"
  echo "    uninstall:   Uninstalls the corresponding Helm chart on cluster 'rime-dev' in specified namespace."
  echo "    clean:       Delete all pvcs in a namespace to clean specified namespace."
  echo "  Note that control plane will be installed as rime-<namespace> and agent as rime-agent"
  echo ""
}

helm_dev() {
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
