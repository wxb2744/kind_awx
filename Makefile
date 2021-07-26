all: kind kubectl ingress awx

kind:
	kind create cluster --image kindest/node:v1.19.11 --config kind.yml

kubectl: 
	$(eval MASTER_IP=$(shell docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' kind-control-plane))
	sed -i "s/^    server:.*/    server: https:\/\/$(MASTER_IP):6443/" /root/.kube/config

ingress:
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

awx:
	kubectl apply -f password.yml
	kubectl apply -f https://raw.githubusercontent.com/ansible/awx-operator/0.12.0/deploy/awx-operator.yaml
	@read -p "FQDN: " FQDN \
	&& sed -i "s/^  hostname:.*/  hostname: $$FQDN/" /root/kind_awx//awx.yml
	kubectl apply -f awx.yml

clean:
	kind delete cluster

fix: kubectl
<<<<<<< HEAD
	kubectl delete ingress awx-ingress
	kubectl replace -f awx.yml
	kubectl apply -f awx.yml

import:
	@read -p "FQDN: " FQDN \
        && awx --conf.hostname $$FQDN conf.username admin conf.password password -k import < export.txt
=======
	kubectl --insecure-skip-tls-verify delete ingress awx-ingress
	kubectl --insecure-skip-tls-verify replace -f awx.yml
	kubectl --insecure-skip-tls-verify apply -f awx.yml
>>>>>>> 8bdde73da8e0483f58e28c8cd46eca22e1abdf3b
