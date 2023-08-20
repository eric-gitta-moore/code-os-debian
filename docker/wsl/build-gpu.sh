source .gpu-envrc
docker compose build --build-arg IMAGE_NAME=tensorflow/tensorflow:2.13.0-gpu --build-arg GPU_SUPPORT=on