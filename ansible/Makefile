all: install_ansible install_collections
.PHONY: all

install_ansible:
	pip install -r requirements.txt

install_collections:
	ansible-galaxy install -r galaxy-requirements.yaml
