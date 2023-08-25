all: install_ansible install_collections create_ca
.PHONY: all

install_ansible:
	pip install -r requirements.txt

install_collections:
	ansible-galaxy install -r galaxy-requirements.yaml

create_ca:
	cd ownCA
	ansible-playbook certificates.yaml
