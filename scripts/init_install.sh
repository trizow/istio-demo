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
        if [ -x "$(which $i)" ];  then
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
    if [ $1 == 'srvmgr' ]; then
        for j in services systemctl brew; do
            if [ -x "$(which $j)" ]; then
                if [ $j == "brew" ]; then
                    echo "brew services"
                else
                    echo $j
                fi
            fi
        done
    fi
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
                ${PKGMGR} install kubernetes-helm
                ${PKGMGR} install kubernetes-cli
                ;;	
            centos)
                # yarn
                curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo
                ${PKGMGR} install yarn
                # helm
                curl https://raw.githubusercontent.com/helm/helm/master/scripts/get | bash
                cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
                ${PKGMGR} install kubectl
                ;;
            debian)
                # yarn
                curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | \
                    sudo apt-key add - echo "deb https://dl.yarnpkg.com/debian/ stable main" | \
                    sudo tee /etc/apt/sources.list.d/yarn.list
                sudo apt-get update && sudo apt-get install yarn
                # helm
                curl https://raw.githubusercontent.com/helm/helm/master/scripts/get | bash
                # kubernetes cli
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


