#!/usr/bin/env bash
#
# Installs a k3s cluster with HA and enbedded DB on pi[2-4]
# Removes default storage provider
# Installs MetalLB, NGINX ingress and Longhorn storage provider
# Adds ingress for Longhorn with basic auth
#
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
magenta=$(tput setaf 5)
cyan=$(tput setaf 6)
white=$(tput setaf 7)
reset=$(tput sgr0)

# not working due to bug in cgroups v2
# K3S_CHANNEL=v1.21.3+k3s1

# working
# K3S_CHANNEL="v1.20.9+k3s1"
K3S_CHANNEL="v1.21.2+k3s1"


if [ "`hostname`" = "pi1.home" ]; then
    echo "${magenta}Do not install K3S on pi1.home ${reset}"
    exit 1
elif [ "`hostname`" = "pi2.home" ]; then
    echo "${magenta}Install K3S primary master from channel $K3S_CHANNEL ${reset}"
    curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--cluster-init --disable servicelb --disable traefik" INSTALL_K3S_CHANNEL="${K3S_CHANNEL}" K3S_TOKEN='u0/GRwsyyqFmx+JZ6X/MFcFWL20QSvX4' sh -

    echo "${magenta}Waiting for the cluster to start${reset}"
    NODES_UP=0
    NODES_EXPECTED=3
    while [ ${NODES_UP} -ne ${NODES_EXPECTED} ]; do
        echo "${red}Wait 20sec to start up nodes ${reset}"
        sleep 20
        NODES_UP=$(kubectl get nodes 2>/dev/null | egrep -c "pi[234].home")
        echo "nodes up: ${NODES_UP}"
    done

    echo "${magenta}Remove default storage for K3S${reset}"
    kubectl delete deployment -n kube-system local-path-provisioner

    echo "${magenta}Install MetalLB load balancer${reset}"
    kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.10.2/manifests/namespace.yaml
    kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
    kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.10.2/manifests/metallb.yaml
    kubectl apply -f templates/metallb-config.yaml

    echo "${magenta}Install nginx ingress${reset}"
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    helm repo update
    kubectl create ns ingress-nginx
    helm install ingress-nginx ingress-nginx/ingress-nginx -n ingress-nginx --wait

    echo "${magenta}Install longhorn storage${reset}"
    helm repo add longhorn https://charts.longhorn.io
    helm repo update
    kubectl create namespace longhorn-system
    helm install longhorn longhorn/longhorn --namespace longhorn-system --wait

    echo "${magenta}Creating Longhorn ingress with basic auth${reset}"
    rm -f auth
    USER="Admin"; PASSWORD="zabbix"; echo "${USER}:$(openssl passwd -stdin -apr1 <<< ${PASSWORD})" >> auth
    kubectl -n longhorn-system create secret generic basic-auth --from-file=auth
    kubectl -n longhorn-system apply -f templates/longhorn-ingress.yaml
else
    echo "${magenta}Installing K3S secondary master${reset}"
    curl -sfL https://get.k3s.io | K3S_TOKEN='u0/GRwsyyqFmx+JZ6X/MFcFWL20QSvX4' INSTALL_K3S_EXEC="server --disable servicelb --disable traefik" INSTALL_K3S_CHANNEL="${K3S_CHANNEL}" K3S_URL=https://pi2:6443 sh -
fi
