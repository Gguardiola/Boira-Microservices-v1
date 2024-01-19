#!/bin/bash
#Used when i have to delete all microservices and start from scratch
db_volume=boira-stuff_postgres_data;

echo "Stopping containers...";
docker stop $(docker ps -aq);
echo "Deleting images and caché...";
docker system prune -a;
echo "Deleting Database Volume..."
docker volume rm $db_volume;
echo "Done!"