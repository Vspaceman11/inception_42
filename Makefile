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

clean:
	@docker compose -f srcs/docker-compose.yml down --rmi all --volumes --remove-orphans

fclean: clean
	@sudo rm -rf /home/vpushkar/data/wordpress/*
	@sudo rm -rf /home/vpushkar/data/mariadb/*

re: fclean all

.PHONY: all prepare build up down clean fclean re