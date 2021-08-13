all: kind kubectl ingress awx

kind:
	kind create cluster --image kindest/node:v1.19.11 --config kind.yml
#	docker stop kind-control-plane
#	docker update --restart always kind-control-plane
#	docker start kind-control-plane
#	echo "Pausing for kind to restart"
#	sleep 15

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
	cp /root/kind_awx/awx.yml /root/.kube/
	kubectl apply -f /root/.kube/awx.yml

clean:
	kind delete cluster

fix: kubectl
	kubectl --insecure-skip-tls-verify delete ingress awx-ingress
	kubectl --insecure-skip-tls-verify replace -f /root/.kube/awx.yml
	#@read -p "FQDN: " FQDN \
	#&& sed -i "s/^  hostname:.*/  hostname: $$FQDN/" /root/kind_awx//awx.yml
	kubectl --insecure-skip-tls-verify apply -f /root/.kube/awx.yml

import:
	$(eval MASTER_IP=$(shell docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' kind-control-plane))
	@read -p "FQDN: " FQDN \
	&& echo "$(MASTER_IP) $$FQDN" >> /etc/hosts \
	&& awx --conf.host https://$$FQDN --conf.username admin --conf.password password -k import < export.txt

export:
	$(eval MASTER_IP=$(shell docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' kind-control-plane))
	@read -p "FQDN: " FQDN \
	&& echo "$(MASTER_IP) $$FQDN" >> /etc/hosts \
	&& awx --conf.host https://$$FQDN --conf.username admin --conf.password password -k export > export.txt
