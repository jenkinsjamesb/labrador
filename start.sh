#!/bin/bash
sudo docker system prune -fa
sudo docker compose -f ~/labrador/$1/$1-compose.yml --env-file ~/labrador/.env pull
sudo docker compose -f ~/labrador/$1/$1-compose.yml --env-file ~/labrador/.env up
