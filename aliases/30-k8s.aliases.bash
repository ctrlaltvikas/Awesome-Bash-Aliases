#!/usr/bin/env bash
# ==============================================================================
# ☸️ 30-k8s.aliases.bash — Kubectl Shortcuts, Namespace Switchers & Diagnostics
# ==============================================================================
# Production-ready Kubernetes shortcuts, context/namespace ergonomics, pod log
# streaming, port forwarding, rollout tracking, and cluster troubleshooting tools.
#
# Part of the Awesome Bash Aliases suite.
# Compatible with Bash 3.2+, Bash 4+, Bash 5+, and Zsh.
# ==============================================================================

# ------------------------------------------------------------------------------
# 🎯 Core Kubectl Operations
# ------------------------------------------------------------------------------

# @name: k
# @category: Kubernetes
# @description: Short alias for the kubectl command-line tool.
# @os: cross-platform
alias k='kubectl'

# @name: kg
# @category: Kubernetes
# @description: Display one or many Kubernetes API resources.
# @os: cross-platform
alias kg='kubectl get'

# @name: kd
# @category: Kubernetes
# @description: Show detailed state of one or more Kubernetes resources.
# @os: cross-platform
alias kd='kubectl describe'

# @name: ka
# @category: Kubernetes
# @description: Apply a configuration to a resource by filename or stdin.
# @os: cross-platform
alias ka='kubectl apply -f'

# @name: kdel
# @category: Kubernetes
# @description: Delete resources by file names, stdin, resources and names.
# @os: cross-platform
alias kdel='kubectl delete'

# @name: ke
# @category: Kubernetes
# @description: Edit a Kubernetes resource directly in your text editor.
# @os: cross-platform
alias ke='kubectl edit'

# ------------------------------------------------------------------------------
# 📦 Workload & Cluster Resource Queries
# ------------------------------------------------------------------------------

# @name: kgp
# @category: Kubernetes
# @description: List pods in the active namespace.
# @os: cross-platform
alias kgp='kubectl get pods'

# @name: kgpa
# @category: Kubernetes
# @description: List all pods across all cluster namespaces.
# @os: cross-platform
alias kgpa='kubectl get pods --all-namespaces'

# @name: kgpw
# @category: Kubernetes
# @description: Watch pod creation, state transitions, and termination live.
# @os: cross-platform
alias kgpw='kubectl get pods --watch'

# @name: kgd
# @category: Kubernetes
# @description: List deployments in the active namespace.
# @os: cross-platform
alias kgd='kubectl get deployments'

# @name: kgs
# @category: Kubernetes
# @description: List services in the active namespace.
# @os: cross-platform
alias kgs='kubectl get services'

# @name: kgi
# @category: Kubernetes
# @description: List ingress resources in the active namespace.
# @os: cross-platform
alias kgi='kubectl get ingress'

# @name: kgn
# @category: Kubernetes
# @description: List all worker and control plane nodes in the cluster.
# @os: cross-platform
alias kgn='kubectl get nodes'

# @name: kgns
# @category: Kubernetes
# @description: List all namespaces defined in the cluster.
# @os: cross-platform
alias kgns='kubectl get namespaces'

# @name: kgcm
# @category: Kubernetes
# @description: List ConfigMaps in the active namespace.
# @os: cross-platform
alias kgcm='kubectl get configmaps'

# @name: kgsec
# @category: Kubernetes
# @description: List Secrets in the active namespace.
# @os: cross-platform
alias kgsec='kubectl get secrets'

# @name: kgpv
# @category: Kubernetes
# @description: List PersistentVolumes in the cluster.
# @os: cross-platform
alias kgpv='kubectl get persistentvolumes'

# @name: kgpvc
# @category: Kubernetes
# @description: List PersistentVolumeClaims in the active namespace.
# @os: cross-platform
alias kgpvc='kubectl get persistentvolumeclaims'

# ------------------------------------------------------------------------------
# 🔍 Detailed Resource Descriptions
# ------------------------------------------------------------------------------

# @name: kdp
# @category: Kubernetes
# @description: Describe detailed status and events of a specified pod.
# @os: cross-platform
alias kdp='kubectl describe pod'

# @name: kdd
# @category: Kubernetes
# @description: Describe detailed status and events of a specified deployment.
# @os: cross-platform
alias kdd='kubectl describe deployment'

# @name: kdn
# @category: Kubernetes
# @description: Describe detailed status and metrics of a specified cluster node.
# @os: cross-platform
alias kdn='kubectl describe node'

# ------------------------------------------------------------------------------
# 📜 Logging, Execution & Port Forwarding
# ------------------------------------------------------------------------------

# @name: kl
# @category: Kubernetes
# @description: Print the logs for a container in a pod.
# @os: cross-platform
alias kl='kubectl logs'

# @name: klf
# @category: Kubernetes
# @description: Follow and stream the last 200 log lines from a pod container.
# @os: cross-platform
alias klf='kubectl logs --follow --tail=200'

# @name: kexec
# @category: Kubernetes
# @description: Execute an interactive command inside a target pod container.
# @os: cross-platform
alias kexec='kubectl exec -it'

# @name: kpf
# @category: Kubernetes
# @description: Forward one or more local ports to a pod or service.
# @os: cross-platform
kpf() {
    if [ "$#" -lt 2 ]; then
        printf 'Usage: kpf <resource> <local-port:remote-port> [additional-options]\n' >&2
        return 2
    fi
    kubectl port-forward "$@"
}

# ------------------------------------------------------------------------------
# 🔀 Context & Namespace Switchers
# ------------------------------------------------------------------------------

# @name: kctx
# @category: Kubernetes
# @description: Display current active Kubernetes context name.
# @os: cross-platform
alias kctx='kubectl config current-context'

# @name: kctxs
# @category: Kubernetes
# @description: List all available contexts in kubeconfig.
# @os: cross-platform
alias kctxs='kubectl config get-contexts'

# @name: kns
# @category: Kubernetes
# @description: Display currently configured default namespace in active context.
# @os: cross-platform
alias kns='kubectl config view --minify --output "jsonpath={..namespace}"'

# @name: kuse
# @category: Kubernetes
# @description: Switch the active Kubernetes context to a specified target.
# @os: cross-platform
kuse() {
    if [ "$#" -ne 1 ]; then
        printf 'Usage: kuse <context-name>\n' >&2
        return 2
    fi
    kubectl config use-context "$1"
}

# @name: knamespace
# @category: Kubernetes
# @description: Change the default namespace for the active Kubernetes context.
# @os: cross-platform
knamespace() {
    if [ "$#" -ne 1 ]; then
        printf 'Usage: knamespace <namespace>\n' >&2
        return 2
    fi
    kubectl config set-context --current --namespace="$1"
}

# ------------------------------------------------------------------------------
# 🚀 Rollout Management & API Exploration
# ------------------------------------------------------------------------------

# @name: kroll
# @category: Kubernetes
# @description: Watch the rollout status of a deployment until completion.
# @os: cross-platform
alias kroll='kubectl rollout status'

# @name: krestart
# @category: Kubernetes
# @description: Trigger rolling restart of a deployment or daemonset.
# @os: cross-platform
alias krestart='kubectl rollout restart'

# @name: khistory
# @category: Kubernetes
# @description: View previous rollout revision history for a workload.
# @os: cross-platform
alias khistory='kubectl rollout history'

# @name: kundoroll
# @category: Kubernetes
# @description: Roll back workload to previous deployment revision.
# @os: cross-platform
alias kundoroll='kubectl rollout undo'

# @name: kapi
# @category: Kubernetes
# @description: List the complete set of API resources supported on the server.
# @os: cross-platform
alias kapi='kubectl api-resources'

# @name: kexplain
# @category: Kubernetes
# @description: Get documentation for a resource field in the terminal.
# @os: cross-platform
alias kexplain='kubectl explain'

# @name: kdiff
# @category: Kubernetes
# @description: Diff live cluster state against a proposed resource manifest.
# @os: cross-platform
alias kdiff='kubectl diff -f'

# ------------------------------------------------------------------------------
# 🩺 Cluster Diagnostics & Troubleshooting
# ------------------------------------------------------------------------------

# @name: kev
# @category: Kubernetes
# @description: List cluster events sorted chronologically by timestamp.
# @os: cross-platform
alias kev='kubectl get events --sort-by=.metadata.creationTimestamp'

# @name: ktop
# @category: Kubernetes
# @description: Display resource (CPU/memory) usage of nodes or pods.
# @os: cross-platform
alias ktop='kubectl top'

# @name: ktopn
# @category: Kubernetes
# @description: Display CPU and memory utilization across cluster nodes.
# @os: cross-platform
alias ktopn='kubectl top nodes'

# @name: ktopp
# @category: Kubernetes
# @description: Display CPU and memory utilization across pods in namespace.
# @os: cross-platform
alias ktopp='kubectl top pods'

# @name: kfailedpods
# @category: Kubernetes
# @description: Query pods across all namespaces that are not in Running or Completed state.
# @os: cross-platform
alias kfailedpods='kubectl get pods --field-selector=status.phase!=Running,status.phase!=Succeeded --all-namespaces'

# @name: kdebug
# @category: Kubernetes
# @description: Attach an ephemeral debug container with troubleshooting tools to a pod.
# @os: cross-platform
kdebug() {
    if [ "$#" -lt 1 ]; then
        printf 'Usage: kdebug <pod> [debug-image]\n' >&2
        return 2
    fi

    local pod="$1"
    local image="${2:-busybox:1.36}"

    kubectl debug -it "$pod" --image="$image"
}

# ------------------------------------------------------------------------------
# ⛵ Helm Operations
# ------------------------------------------------------------------------------

# @name: hm
# @category: Kubernetes
# @description: Unambiguous shortcut for Helm package manager.
# @os: cross-platform
alias hm='helm'

# @name: hmls
# @category: Kubernetes
# @description: List Helm releases in the current active namespace.
# @os: cross-platform
alias hmls='helm list'

# @name: hmlsa
# @category: Kubernetes
# @description: List Helm releases across all cluster namespaces.
# @os: cross-platform
alias hmlsa='helm list --all-namespaces'

# @name: hmrepo
# @category: Kubernetes
# @description: List all configured Helm chart repositories.
# @os: cross-platform
alias hmrepo='helm repo list'

# @name: hmrepou
# @category: Kubernetes
# @description: Update information of available charts locally from chart repositories.
# @os: cross-platform
alias hmrepou='helm repo update'

# @name: hmsearch
# @category: Kubernetes
# @description: Search repositories for keyword matches in Helm charts.
# @os: cross-platform
alias hmsearch='helm search repo'

# @name: hmstatus
# @category: Kubernetes
# @description: Display the status of a named Helm release.
# @os: cross-platform
alias hmstatus='helm status'

# @name: hmhistory
# @category: Kubernetes
# @description: Fetch historical release revisions for a Helm deployment.
# @os: cross-platform
alias hmhistory='helm history'

# @name: hmrollback
# @category: Kubernetes
# @description: Roll back a release to a previous historical revision.
# @os: cross-platform
alias hmrollback='helm rollback'

# @name: hmtemplate
# @category: Kubernetes
# @description: Render chart templates locally and display output.
# @os: cross-platform
alias hmtemplate='helm template'

# @name: hmlint
# @category: Kubernetes
# @description: Examine a chart for possible issues and verify best practices.
# @os: cross-platform
alias hmlint='helm lint'
