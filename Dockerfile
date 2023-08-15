FROM debian:12 AS base

# =========== 配置 zsh =============
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
    apt install git curl wget zsh sudo vim -y && \
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
    echo "$USER_NAME:$USER_PWD" | chpasswd && \
    echo "root:$USER_PWD" | chpasswd && \
    echo "$USER_PWD" | chsh -s $(which zsh)

USER ${USER_NAME}

RUN echo "$USER_PWD" | chsh -s $(which zsh)

WORKDIR ~

# ohmyzsh
RUN echo 'Y' | sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
    git clone https://github.com/skywind3000/z.lua.git && \
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && \
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k && \
    sed -i.bak 's/plugins=(git)/plugins=(\ngit\ncommand-not-found\ncolored-man-pages\nvi-mode\nzsh-autosuggestions\nzsh-syntax-highlighting\n)/' ~/.zshrc && \
    sed -i 's#ZSH_THEME="robbyrussell"#ZSH_THEME="powerlevel10k/powerlevel10k"#' ~/.zshrc

# 启用 256 色 xterm
RUN cat <<'EOF' >> ~/.zshrc

# ZSH 初始化
eval "$(lua ~/z.lua/z.lua  --init zsh once enhanced)"

# truecolor xterm
if [[ "$TERM" == "xterm" ]]; then
export TERM=xterm-256color
fi
EOF

# =========== 配置 conda =============
# =========== 配置 nvm =============
# =========== 配置 jenv =============
# =========== 配置 c++ =============
# =========== 配置 guifont =============
# =========== 配置 binfmt =============

CMD [ "tail", "-f", "/dev/null" ]
