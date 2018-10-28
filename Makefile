SHELL := /bin/bash
lPHONY: help
# COLORS
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
RESET  := $(shell tput -Txterm sgr0)
# Latest Istio
VERSION := $(shell curl -L -s https://api.github.com/repos/istio/istio/releases/latest | grep tag_name | sed "s/ *\"tag_name\": *\"\\(.*\\)\",*/\\1/" | sed 's/[[:blank:]]*\\$$//')
# Package and services
PKGMGR := $(shell sh scripts/init_install.sh pkgmgr)
SRVMGR := $(shell sh scripts/init_install.sh srvmgr)
TARGET_MAX_CHAR_NUM=20

## install dependencies
install:
	curl -L https://git.io/getLatestIstio | sh - 
	@echo "ISTO Version is: $(VERSION)"
	$(shell ${SHELL} scripts/init_install.sh install)

## update istio version
update:
	rm -rf istio-*
	curl -L https://git.io/getLatestIstio | sh - 
	@echo "ISTO Version is: $(VERSION)"

init-nginx:
	cp policy/nginx/nginx.conf /usr/local/etc/nginx/nginx.conf
	${SRVMGR} restart nginx

restart-nginx:
	${SRVMGR} restart nginx

## raw gradle build
gradle-build:
	gradle build -p microservice

## build docker container
build:
	docker-compose -f microservice/docker-compose.yaml build

## build docker container
push:
	docker-compose -f microservice/docker-compose.yaml push

## install helm
helm-install:
	$(shell ${SHELL} scripts/init_install.sh install)

## check mtls status
show-mtls:
	./istio-$(VERSION)/bin/istioctl authn tls-check

## show proxy synchronization status
proxy-status:
	./istio-$(VERSION)/bin/istioctl proxy-status

## label namespace
label-namespace:
	kubectl create namespace development
	kubectl label namespace development istio-injection=enabled
	kubectl get namespace -L istio-injection

## initialise kubernetes
initialise:
	curl -L https://git.io/getLatestIstio | sh -
	@echo "ISTO Version is: $(VERSION)"
	sh init_kube.sh
	
## deploy microservice v1
deploy-v1:
	kubectl apply -f policy/microservice-v1/

## deploy microservice v2
deploy-v2:
	kubectl apply -f policy/microservice-v2/

## delete microservice-related resources
clean:
	kubectl --ignore-not-found=true delete -f policy/microservice-v1/
	kubectl --ignore-not-found=true delete -f policy/microservice-v2/
	kubectl --ignore-not-found=true delete -f policy/istio/base
	kubectl --ignore-not-found=true delete -f policy/istio/canary

## delete all resources
clean-all:
	kubectl --ignore-not-found=true delete -f policy/microservice-v1/
	kubectl --ignore-not-found=true delete -f policy/microservice-v2/
	kubectl --ignore-not-found=true delete -f policy/istio/base
	kubectl --ignore-not-found=true delete -f policy/istio/canary
	kubectl --ignore-not-found=true delete -f istio-${VERSION}/install/kubernetes/helm/istio/templates/crds.yaml
	helm del --purge istio
	kubectl -n istio-system delete job --all
	kubectl delete namespace istio-system

## microservice policy
microservice-policy:
	kubectl apply -f policy/istio/base
	kubectl apply -f policy/istio/canary
	kubectl apply -f policy/istio/canary/vs.100-v1.yaml

## reapply istio policies
refresh-policy:
	kubectl --ignore-not-found=true delete -f policy/istio/base
	kubectl --ignore-not-found=true delete -f policy/istio/canary
	kubectl apply -f policy/istio/base
	kubectl apply -f policy/istio/canary/vs.100-v1.yaml

## deploy canary with a 90-10 split
canary:
	kubectl apply -f policy/istio/canary/vs.90-v1.yaml

## rollback canary deployment
canary-rollback:
	kubectl apply -f policy/istio/canary/vs.100-v1.yaml
install-ingress:
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/mandatory.yaml
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/provider/cloud-generic.yaml
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/provider/baremetal/service-nodeport.yaml

access-observability:
	kubectl apply -f policy/istio/observability/

get-ingress-nodeport:
	echo "export NODE_PORT="`kubectl -n ingress-nginx get service ingress-nginx -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}'`

traffic:
	siege -t 100 -r 10 -c 2 -v demo.microservice.local/color

## install istio control plane
install-istio:
	helm init
	helm upgrade --install --force istio istio-${VERSION}/install/kubernetes/helm/istio \
		--namespace istio-system \
		--set ingress.enabled=true \
		--set gateways.istio-ingressgateway.enabled=true \
		--set gateways.istio-egressgateway.enabled=true \
		--set gateways.istio-ingressgateway.type=NodePort \
		--set gateways.istio-egressgateway.type=NodePort \
		--set galley.enabled=true \
		--set sidecarInjectorWebhook.enabled=true \
		--set mixer.enabled=true \
		--set prometheus.enabled=true \
		--set global.hub=istio \
		--set global.tag=${VERSION} \
		--set global.imagePullPolicy=Always \
		--set global.proxy.image=proxyv2 \
		--set global.proxy.envoyStatsd.enabled=true \
		--set global.proxy.envoyStatsd.host=istio-statsd-prom-bridge \
		--set global.proxy.envoyStatsd.port=9125 \
		--set global.mtls.enabled=true \
		--set security.selfSigned=true \
		--set global.enableTracing=true \
		--set global.proxy.autoInject=disabled \
		--set grafana.enabled=true \
		--set kiali.enabled=true \
		--set kiali.hub=kiali \
		--set kiali.tag=latest \
		--set tracing.enabled=true \
		--timeout 600 



## Show help
help:
	@echo ''
	@echo 'Usage:'
	@echo '  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")-1); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "  ${YELLOW}%-$(TARGET_MAX_CHAR_NUM)s${RESET} ${GREEN}%s${RESET}\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)
