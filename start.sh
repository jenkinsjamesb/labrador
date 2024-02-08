#!/bin/bash
sudo docker system prune -fa
sudo docker compose -f ~/leadlab/$1/$1-compose.yml --env-file ~/leadlab/.env pull
sudo docker compose -f ~/leadlab/$1/$1-compose.yml --env-file ~/leadlab/.env up
