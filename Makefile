ENV_FILE ?= .env
COMPOSE := docker compose --env-file $(ENV_FILE) run --rm racadm

.PHONY: help build
.PHONY: status info sysinfo inventory version sel
.PHONY: power-on power-off restart power-cycle hard-reset
.PHONY: idrac-reset idrac-info
.PHONY: cmd

help: ## Show available commands
	@echo "Dell PowerEdge server management via iDRAC7 (RACADM)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*##"}; {printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Custom command:  make cmd CMD=\"<racadm_command>\""
	@echo "Custom env file: make <target> ENV_FILE=.env.node02"

# -- Build --

build: ## Build racadm:latest image
	docker compose build racadm

# -- Info --

status: ## Server power status
	$(COMPOSE) serveraction powerstatus

# -- Power on/off--

power-on: ## Power on the server
	$(COMPOSE) serveraction powerup

power-off: ## Graceful shutdown
	$(COMPOSE) serveraction graceshutdown

restart: ## Graceful restart (shutdown + power on)
	$(COMPOSE) serveraction graceshutdown
	@echo "Waiting for shutdown (30s)..."
	@sleep 30
	$(COMPOSE) serveraction powerup

power-cycle: ## Power cycle (hard cut + power on)
	$(COMPOSE) serveraction powercycle

hard-reset: ## Hard reset (forced reboot)
	$(COMPOSE) serveraction hardreset

# -- Custom command --

cmd: ## Run any RACADM command (make cmd CMD="...")
	$(COMPOSE) $(CMD)
