docker run -d \
    --network host \
    -v ~/.ssh:/home/linux/.ssh \
    -v ~/workspace:/mnt/workspace \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -e DISPLAY=host.docker.internal:0 \
    code-os-debian