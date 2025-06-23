DOCKER_COMPOSE = docker-compose
DOCKER_COMPOSE_FILE = ./srcs/docker-compose.yml
PROJECT_NAME = inception

# Colors for output
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[0;33m
BLUE = \033[0;34m
NC = \033[0m # No Color

# Default target
all: build up

build:
	@echo "$(YELLOW)Building...$(NC)"
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) build
	@echo "$(GREEN)Building successful!$(NC)"

up: build
	@echo "$(YELLOW)Building and starting services...$(NC)"
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) up
	@echo "$(GREEN)All services are up and running!$(NC)"
	@echo "$(BLUE)WordPress is available at: https://dangtran.42.fr$(NC)"

start:
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) up -d

stop:
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) stop

restart:
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) stop
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) up
	
logs:
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) logs

status:
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) ps

ps: status

# Rebuild everything
re: fclean all

# Stop services
down:
	@echo "$(YELLOW)Stopping services...$(NC)"
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) down
	@echo "$(GREEN)Services stopped successfully!$(NC)"

# Clean containers and networks
clean: down
	@echo "$(YELLOW)Cleaning containers, networks and images...$(NC)"
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) down -v --rmi all
	@docker system prune -f
	@echo "$(GREEN)Cleanup completed!$(NC)"

# Full cleanup including data
fclean: clean
	@echo "$(RED)Performing full cleanup (including data directories)...$(NC)"
	@docker stop $$(docker ps -qa) 2>/dev/null || echo "No containers to stop"
	@docker rm $$(docker ps -qa) 2>/dev/null || echo "No containers to remove"
	@docker rmi -f $$(docker images -qa) 2>/dev/null || echo "No images to remove"
	@docker volume rm $$(docker volume ls -q) 2>/dev/null || echo "No volumes to remove"
	@docker network rm $$(docker network ls -q --filter type=custom) 2>/dev/null || echo "No custom networks to remove"
#   @sudo rm -rf $(DATA_DIR) 2>/dev/null || echo "Data directory already clean"
	@docker system prune -af --volumes
	@echo "$(GREEN)Full cleanup completed!$(NC)"

.PHONY : all down build up start stop clean fclean re restart logs status ps