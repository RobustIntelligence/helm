#!/bin/sh

# NOTE: THIS FILE IS DEPRECATED. Use helm_dev.sh to manage dev installations of the agent and controlplane.
# This file was originally used prior to the DP/CP split.
ProgName=$(basename $0)

error() {
    printf '%s\n' "$1" >&2
    exit 1
}

install_or_upgrade() {
    cmd="$1"
    namespace="$2"
    aws eks update-kubeconfig --name rime-dev --region us-west-2 || error "Unable to switch to EKS cluster 'rime-dev'"
    kubectl get namespace "${namespace}" || error "Namespace '${namespace}' not found on cluster 'rime-dev'"
    kubectl -n "${namespace}" get secret rimecreds || error "Registry credential 'rimecreds' not found in namespace '${namespace}' on cluster 'rime-dev'"
    pushd rime
    helm -n "${namespace}" dependency update &&
    helm -n "${namespace}" "${cmd}" --debug --values "../../aws/dev_cluster/dev_cluster_values/values_${namespace}.yaml" "rime-${namespace}" ./
    # restart all deployments in namespace.
    kubectl -n "${namespace}" rollout restart deployment
    popd
}

sub_install() {
    install_or_upgrade install "$1"
}

sub_upgrade() {
    install_or_upgrade upgrade "$1"
}

sub_uninstall() {
    namespace="$1"
    aws eks update-kubeconfig --name rime-dev --region us-west-2 || error "Unable to switch to EKS cluster 'rime-dev'"
    kubectl get namespace "${namespace}" || error "Namespace '${namespace}' not found on cluster 'rime-dev'"
    helm -n "${namespace}" uninstall "rime-${namespace}"
}

sub_help() {
    echo "Usage: $ProgName <subcommand> <namespace>\n"
    echo "Subcommands:"
    echo "    install:     Installs the rime Helm chart on cluster 'rime-dev' in namespace <namespace> under name 'rime-<namespace>'."
    echo "    upgrade:     Upgrades the rime Helm chart on cluster 'rime-dev' in namespace <namespace> under name 'rime-<namespace>'."
    echo "    uninstall:   Uninstalls the rime Helm chart named 'rime-<namespace> on cluster 'rime-dev' in namespace <namespace>."
    echo ""
}

subcommand=$1
case $subcommand in
    "" | "-h" | "--help")
        sub_help
        ;;
    *)
        shift
        sub_${subcommand} $@
        if [ $? = 127 ]; then
            echo "Error: '$subcommand' is not a known subcommand." >&2
            echo "       Run '$ProgName --help' for a list of known subcommands." >&2
            exit 1
        fi
        ;;
esac

# Set the current namespace to the namespace that was just altered before exit.
kubectl config set-context --current --namespace="$1"
