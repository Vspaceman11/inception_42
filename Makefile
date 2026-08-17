NAME = inception

all: prepare build up

prepare:
	@mkdir -p /home/vpushkar/data/wordpress
	@mkdir -p /home/vpushkar/data/mariadb

build:
	@docker compose -f srcs/docker-compose.yml build

up: prepare
	@docker compose -f srcs/docker-compose.yml up -d

down:
	@docker compose -f srcs/docker-compose.yml down

clean: down
	@docker system prune -a --force

fclean: clean
	@sudo rm -rf /home/vpushkar/data/wordpress/*
	@sudo rm -rf /home/vpushkar/data/mariadb/*
	@docker volume rm $$(docker volume ls -q) 2>/dev/null || true

re: fclean all

.PHONY: all prepare build up down clean fclean re