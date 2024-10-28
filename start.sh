#!/bin/bash
BASEDIR=$(dirname "$0")
(cd $BASEDIR/$1 && 
sudo docker system prune -fa
sudo docker compose pull
sudo docker compose up)