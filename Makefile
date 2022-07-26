#!/usr/bin/make

SHELL := /bin/bash

.PHONY : help init down up cli serve change-php
.DEFAULT_GOAL : help

DOCKER_ENV_FILE = .env

ifneq ("$(wildcard $(DOCKER_ENV_FILE))","")
 	include $(DOCKER_ENV_FILE)
endif

help: ## Show this help
	@printf "\033[33m%s:\033[0m\n" 'Available commands'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "  \033[32m%-18s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

init: ## First command
	@if [ ! -f $(DOCKER_ENV_FILE) ]; \
	then \
		cp $(DOCKER_ENV_FILE).example $(DOCKER_ENV_FILE); \
		sed -i -e 's/HOST_FILES_OWNER_UID=.*/HOST_FILES_OWNER_UID=$(shell id -u)/' \
			-e 's/HOST_FILES_OWNER_NAME=.*/HOST_FILES_OWNER_NAME=$(USER)/' $(DOCKER_ENV_FILE); \
	fi;

down: ## Stops containers and removes containers, networks, volumes, and images created by Up
	@docker-compose down

up: ## Up containers
	@docker-compose --env-file $(DOCKER_ENV_FILE) up -d

cli: ## Connect to php container cli
	@docker exec -it $(COMPOSE_PROJECT_NAME)_php /bin/sh

serve: ## Run php server
	@docker exec -it $(COMPOSE_PROJECT_NAME)_php /bin/sh -c "php -S 0.0.0.0:80"

change-php: ## Change php version
	@read -p "Enter new php version (Current $(PHP_VERSION)): " VERSION; \
	sed -i -e "s/PHP_VERSION=.*/PHP_VERSION=$$VERSION/" $(DOCKER_ENV_FILE)
	@docker-compose --env-file $(DOCKER_ENV_FILE) up -d --no-deps --build php
