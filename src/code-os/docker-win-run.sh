docker run -d \
    --network host \
    -v ~/.ssh:/home/linux/.ssh \
    -v ~/workspace:/mnt/workspace \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v /mnt/wslg:/mnt/wslg \
    -e DISPLAY=unix$DISPLAY \
    code-os-debian