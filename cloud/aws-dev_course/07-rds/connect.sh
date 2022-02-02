#!/usr/bin/bash

psql \
   --host=task7-images.cvcp8dw2iqkk.eu-west-1.rds.amazonaws.com \
   --port=5432 \
   --username=evgenii \
   --password \
   --dbname=flaskApp
