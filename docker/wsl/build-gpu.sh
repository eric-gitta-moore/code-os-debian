source .envrc
docker compose build --build-arg IMAGE_NAME=tensorflow/tensorflow:latest-gpu --build-arg GPU_SUPPORT=on