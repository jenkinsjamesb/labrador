#!/bin/bash
sudo docker compose -f ~/leadlab/$1/$1-compose.yml pull
sudo docker compose -f ~/leadlab/$1/$1-compose.yml --env-file ~leadlab/.env up
