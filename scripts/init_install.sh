#!/bin/bash

if [[ -z $1 ]]; then
    echo "error, must have pkgmgr, srvmgr or install"
    exit;
fi

chk_pkgmgr() 
{
    for i in apt-get yum brew; do
        if [ -x "$(which $i 2>/dev/null)" ];  then
            case $i in
                apt-get)
                    echo "sudo apt-get -y"
                    export OS="debian"
		    export NGINX="/etc/nginx/"
                    ;;
                yum)
                    echo "sudo yum -y"
                    export OS="centos"
		    export NGINX="/usr/local/etc/nginx/"
                    ;;
                brew)
                    echo "brew"
                    export OS="osx"
		    export NGINX="/usr/local/etc/nginx/"
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
	    elif [ -e "/etc/init.d/nginx" ]; then
		echo "/etc/init.d/nginx"
	    else
                echo $j
            fi
        fi
    done
}

centos_install()
{
    sudo yum -y install siege nodejs nginx
    echo "Install yarn.."
    curl -s --location https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo
    sudo yum -y install yarn
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
    sudo yum -y install kubectl
}

deb_install()
{
    # Use the below to install libvirt and enable for clients
    # sudo apt install qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils libguestfs-tools genisoimage virtinst libosinfo-bin
    # sudo adduser vivek libvirt
    # sudo adduser vivek libvirt-qemu
    # newgrp libvirt
    # newgrp libvirt-qemu

    sudo apt-get -y install siege nodejs nginx
    echo "Install yarn.."
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | \
        sudo apt-key add - 
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | \
        sudo tee /etc/apt/sources.list.d/yarn.list
    sudo apt-get -y update && sudo apt-get -y install yarn
    echo "Install helm.."
    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get | bash
    echo "Install kubectl.."
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
        sudo apt-key add - 
    echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" |\
        sudo tee -a /etc/apt/sources.list.d/kubernetes.list
    sudo apt-get -y update && sudo apt-get -y install kubectl
}

osx_install()
{
    brew install yarn siege nodejs nginx kubernetes-helm kubernetes-cli
}


case $1 in
    pkgmgr)
        chk_pkgmgr
        exit;
        ;;
    srvmgr)
        chk_srvmgr
        exit;
        ;;
    install)
        PKGMGR=eval chk_pkgmgr
        SRVMGR=eval chk_srvmgr
        echo "OS detected is: ${OS}"
        case ${OS} in
            osx)
                osx_install
                ;;	
            centos)
                centos_install
                ;;
            debian)
                deb_install
                ;;
        esac
esac


