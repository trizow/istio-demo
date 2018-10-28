#!/bin/bash


if [[ -z $1 ]]; then
    echo "error, must have either pkgmgr or srvmgr"
    exit;
else
    ACTION=$1
fi

chk_pkgmgr() 
{
    for i in apt-get yum brew; do
        if [ -x "$(which $i 2>/dev/null)" ];  then
            case $i in
                apt-get)
                    echo "sudo apt-get -y"
                    OS="debian"
                    ;;
                yum)
                    echo "sudo yum -y"
                    OS="centos"
                    ;;
                brew)
                    echo "brew"
                    OS="osx"
                    ;;
            esac
        fi
    done
}

chk_srvmgr()
{
    for j in services systemctl brew; do
        if [ -x "$(which $j 2>/dev/null)" ]; then
            if [ $j == "brew" ]; then
                echo "brew services"
            else
                echo $j
            fi
        fi
    done
}

case $ACTION in
    pkgmgr)
        chk_pkgmgr
        ;;
    srvmgr)
        chk_srvmgr
        ;;
    install)
        PKGMGR=chk_pkgmgr
        SRVMGR=chk_srvmgr
        ${PKGMGR} install siege
        ${PKGMGR} install nodejs
        ${PKGMGR} install nginx 
        case ${OS} in
            osx)
                echo "Install helm.."
                ${PKGMGR} install kubernetes-helm
                echo "Install kubectl.."
                ${PKGMGR} install kubernetes-cli
                ;;	
            centos)
                echo "Install yarn.."
                curl -s --location https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo
                ${PKGMGR} install yarn
                echo "Install helm.."
                curl -s --location https://raw.githubusercontent.com/helm/helm/master/scripts/get | bash
                cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
                echo "Install kubectl.."
                ${PKGMGR} install kubectl
                ;;
            debian)
                echo "Install yarn.."
                curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | \
                    sudo apt-key add - echo "deb https://dl.yarnpkg.com/debian/ stable main" | \
                    sudo tee /etc/apt/sources.list.d/yarn.list
                sudo apt-get update && sudo apt-get install yarn
                echo "Install helm.."
                curl https://raw.githubusercontent.com/helm/helm/master/scripts/get | bash
                echo "Install kubectl.."
                curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
                    sudo apt-key add - echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" |\
                    sudo tee -a /etc/apt/sources.list.d/kubernetes.list
                ${PKGMGR} install kubectl
                ;;
        esac
        kubectl version
        kubectl create namespace development
        helm init
esac


