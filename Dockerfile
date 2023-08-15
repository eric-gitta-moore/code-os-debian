FROM debian:12 AS base

# http
RUN cat <<'EOF' > /etc/apt/sources.list
# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
deb http://mirror.nju.edu.cn/debian/ bookworm main contrib non-free non-free-firmware
# deb-src http://mirror.nju.edu.cn/debian/ bookworm main contrib non-free non-free-firmware

deb http://mirror.nju.edu.cn/debian/ bookworm-updates main contrib non-free non-free-firmware
# deb-src http://mirror.nju.edu.cn/debian/ bookworm-updates main contrib non-free non-free-firmware

deb http://mirror.nju.edu.cn/debian/ bookworm-backports main contrib non-free non-free-firmware
# deb-src http://mirror.nju.edu.cn/debian/ bookworm-backports main contrib non-free non-free-firmware

deb http://mirror.nju.edu.cn/debian-security bookworm-security main contrib non-free non-free-firmware
# deb-src http://mirror.nju.edu.cn/debian-security bookworm-security main contrib non-free non-free-firmware

# deb http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
# # deb-src http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
EOF

RUN apt update && \
    apt install git curl wget zsh sudo -y && \
    apt install apt-transport-https ca-certificates -y

# https
RUN cat <<'EOF' > /etc/apt/sources.list
# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
deb https://mirror.nju.edu.cn/debian/ bookworm main contrib non-free non-free-firmware
# deb-src https://mirror.nju.edu.cn/debian/ bookworm main contrib non-free non-free-firmware

deb https://mirror.nju.edu.cn/debian/ bookworm-updates main contrib non-free non-free-firmware
# deb-src https://mirror.nju.edu.cn/debian/ bookworm-updates main contrib non-free non-free-firmware

deb https://mirror.nju.edu.cn/debian/ bookworm-backports main contrib non-free non-free-firmware
# deb-src https://mirror.nju.edu.cn/debian/ bookworm-backports main contrib non-free non-free-firmware

deb https://mirror.nju.edu.cn/debian-security bookworm-security main contrib non-free non-free-firmware
# deb-src https://mirror.nju.edu.cn/debian-security bookworm-security main contrib non-free non-free-firmware

# deb https://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
# # deb-src https://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
EOF

RUN apt update

ENV USER_PWD=linux \
    USER_NAME=linux

RUN useradd -ms /bin/bash $USER_NAME && \
    usermod -aG sudo $USER_NAME && \
    echo "$USER_NAME:$USER_PWD" | chpasswd

USER ${USER_NAME}

# 启用 256 色 xterm
RUN cat <<'EOF' >> ~/.zshrc
if [ "$TERM" == "xterm" ]; then
export TERM=xterm-256color
fi
EOF

# # ohmyzsh
# RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# RUN git clone https://github.com/skywind3000/z.lua.git && \
#     git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
#     git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting



CMD [ "tail", "-f", "/dev/null" ]
