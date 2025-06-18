COMPOSE_FILE = srcs/docker-compose.yml
PROJECT_NAME = inception
DATA_DIR = /home/dangtran/data
WORDPRESS_DIR = $(DATA_DIR)/wordpress
MARIADB_DIR = $(DATA_DIR)/mariadb


# Colors for output
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[0;33m
BLUE = \033[0;34m
NC = \033[0m # No Color

# Default target
all: setup up

# Setup data directories
# @usermod -aG docker $(USER) - pour ajouter l'utilisateur au groupe docker
setup:
	@echo "$(YELLOW)Creating data directories...$(NC)"
	@mkdir -p $(WORDPRESS_DIR)
	@mkdir -p $(MARIADB_DIR)
#	@chown -R $(USER):$(USER) $(DATA_DIR)
#	@chmod -R 755 $(DATA_DIR)
	@echo "$(GREEN)Data directories created successfully!$(NC)"

# Build and start services
up: setup
	@echo "$(YELLOW)Building and starting services...$(NC)"
	@cd srcs && docker-compose -f docker-compose.yml -p $(PROJECT_NAME) up
	@echo "$(GREEN)All services are up and running!$(NC)"
	@echo "$(BLUE)WordPress is available at: https://dangtran.42.fr$(NC)"

# Stop services
down:
	@echo "$(YELLOW)Stopping services...$(NC)"
	@cd srcs && docker-compose -f docker-compose.yml -p $(PROJECT_NAME) down
	@echo "$(GREEN)Services stopped successfully!$(NC)"

# Clean containers and networks
clean: down
	@echo "$(YELLOW)Cleaning containers, networks and images...$(NC)"
	@cd srcs && docker-compose -f docker-compose.yml -p $(PROJECT_NAME) down -v --rmi all
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
	@sudo rm -rf $(DATA_DIR) 2>/dev/null || echo "Data directory already clean"
	@docker system prune -af --volumes
	@echo "$(GREEN)Full cleanup completed!$(NC)"

# Rebuild everything
re: fclean all

# Restart services
restart: down up

# Individual service management
start-nginx:
	@cd srcs && docker-compose -f docker-compose.yml -p $(PROJECT_NAME) start nginx

start-wordpress:
	@cd srcs && docker-compose -f docker-compose.yml -p $(PROJECT_NAME) start wordpress

start-mariadb:
	@cd srcs && docker-compose -f docker-compose.yml -p $(PROJECT_NAME) start mariadb

stop-nginx:
	@cd srcs && docker-compose -f docker-compose.yml -p $(PROJECT_NAME) stop nginx

stop-wordpress:
	@cd srcs && docker-compose -f docker-compose.yml -p $(PROJECT_NAME) stop wordpress

stop-mariadb:
	@cd srcs && docker-compose -f docker-compose.yml -p $(PROJECT_NAME) stop mariadb


.PHONY : all down setup up down clean fclean re restart start-nginx start-wordpress start-mariadb stop-nginx stop-wordpress stop-mariadb