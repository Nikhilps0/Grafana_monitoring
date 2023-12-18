#!/bin/bash
hostname=$(hostname)
z=$(ps aux)
while read -r z1
do
   cpu_usage=$cpu_usage$(awk '{print "cpu_usage{process=\""$11"\", pid=\""$2"\"}", $3z}');
done <<< "$z"
while read -r z1
do
   memory_usage=$memory_usage$(awk '{print "memory_usage{process=\""$11"\", pid=\""$2"\"}", $4z}');
done <<< "$z"

curl -X POST -H  "Content-Type: text/plain" --data "$cpu_usage
" http://localhost:9091/metrics/job/node/instance/$hostname

curl -X POST -H  "Content-Type: text/plain" --data "$memory_usage
" http://localhost:9091/metrics/job/node/instance/$hostname

container_info=$(docker ps -a --format '{{.ID}}:{{.Status}}' | awk -F ':' '{print $1, $2}' |  awk '{gsub(/[()]/,"",$3); print}'| awk '{gsub(/[About]/,"1",$3); print}'| awk '{print $1,$2,$3}')

while read -r container
do
    container_id=$(echo "$container" | awk '{print $1}')
    container_status=$(echo "$container" | awk '{print $2}')
    container_valu=$(echo "$container" | awk '{print $3}')
    metrics_data+="metrics_data{container_id=\"$container_id\", container_status=\"$container_status\"} $container_valu"$'\n'
done <<< "$container_info"
curl -X POST -H  "Content-Type: text/plain" --data "$metrics_data
" http://localhost:9091/metrics/job/c_status/instance/$hostname
container_image_info=$(docker images --format '{{.Repository}} {{.Size}}')
while read -r container_image
do
    REPOSITORY=$(echo "$container_image" | awk '{print $1}')
    SIZE=$(echo "$container_image" | awk '{print $2}')
    image_data+="image_data{image_name=\"$REPOSITORY\", image_size=\"$SIZE\"} 1"$'\n'
done <<< "$container_image_info"


curl -X POST -H  "Content-Type: text/plain" --data "$image_data
" http://localhost:9091/metrics/job/c_image_status/instance/$hostname
