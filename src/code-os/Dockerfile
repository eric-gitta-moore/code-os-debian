FROM debian:12 AS base

ARG USER_PWD=linux \
    USER_NAME=linux \
    CONDA_INSTALLER_URL=https://repo.anaconda.com/miniconda/Miniconda3-py39_23.5.2-0-Linux-x86_64.sh \
    NVM_INSTALLER_URL=https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh \ 
    NVM_NODEJS_ORG_MIRROR=https://npmmirror.com/mirrors/node/

SHELL ["/bin/bash", "-c"]
ENV SHELL=/bin/bash
USER root

# =========== 换源 =============
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
    apt install git curl wget zsh sudo vim lua5.2 -y && \
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

# =========== 配置 zsh =============

SHELL ["/usr/bin/zsh", "-c"]
ENV SHELL=/usr/bin/zsh

RUN useradd -ms /bin/bash ${USER_NAME} && \
    usermod -aG sudo ${USER_NAME} && \
    echo "${USER_NAME}:${USER_PWD}" | chpasswd && \
    echo "root:${USER_PWD}" | chpasswd && \
    echo "${USER_PWD}" | chsh -s $(which zsh) && \
    apt update && apt install command-not-found -y && apt update

USER ${USER_NAME}

RUN echo "${USER_PWD}" | chsh -s $(which zsh)

WORKDIR /home/${USER_NAME}

# ohmyzsh
RUN echo 'Y' | sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
    git clone https://github.com/skywind3000/z.lua.git ~/z.lua && \
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && \
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k && \
    sed -i.bak 's/plugins=(git)/plugins=(\ngit\ncommand-not-found\ncolored-man-pages\nvi-mode\nzsh-autosuggestions\nzsh-syntax-highlighting\n)/' ~/.zshrc && \
    sed -i 's#ZSH_THEME="robbyrussell"#ZSH_THEME="powerlevel10k/powerlevel10k"#' ~/.zshrc

RUN cat <<'EOF' >> ~/.zshrc

# ZSH 初始化
eval "$(lua ~/z.lua/z.lua  --init zsh once enhanced)"

# 启用 256 色 xterm
if [[ "$TERM" == "xterm" ]]; then
export TERM=xterm-256color
fi

# 设置语言
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF

RUN cat <<'EOF' | cat - ~/.zshrc > ~/.zshrc.tmp && mv ~/.zshrc.tmp ~/.zshrc
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

EOF

RUN cat <<EOF >> ~/.zshrc

# nvm mirror
export NVM_NODEJS_ORG_MIRROR=${NVM_NODEJS_ORG_MIRROR}
EOF

COPY src/zsh/.p10k.zsh /home/${USER_NAME}/

# =========== 配置中文环境 =============
RUN cat <<'EOF' > ~/.cnrc
export LC_ALL=zh_CN.UTF-8
export LANG=zh_CN.UTF-8
EOF

USER root
RUN sudo apt update && sudo apt install -y fonts-wqy-zenhei fonts-wqy-microhei locales dialog apt-utils man manpages-zh && \
    echo 'locales locales/locales_to_be_generated multiselect en_US.UTF-8 UTF-8, zh_CN.UTF-8 UTF-8' | debconf-set-selections && \
    echo 'locales locales/default_environment_locale select en_US.UTF-8' | debconf-set-selections && \
    rm "/etc/locale.gen" && \
    dpkg-reconfigure --frontend=noninteractive locales

USER ${USER_NAME}


# =========== 配置 conda =============
RUN wget -O ~/conda.sh ${CONDA_INSTALLER_URL} && \
    sh ~/conda.sh -b && \
    eval "$(~/miniconda3/bin/conda shell.zsh hook)" && \
    conda init zsh

# =========== 配置 nvm =============
RUN curl -o- ${NVM_INSTALLER_URL} | bash && \
    source ~/.zshrc && \
    nvm install --lts && \
    nvm install lts/gallium && \
    nvm use lts/gallium && \
    : && \
    npm config set -g registry https://registry.npmmirror.com && \
    npm i -g yarn pnpm && \
    yarn config set registry https://registry.npmmirror.com -g && \
    pnpm config set registry https://registry.npmmirror.com -g

# =========== 配置 java =============
USER root
RUN wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | sudo tee /etc/apt/keyrings/adoptium.asc && \
    echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] https://mirror.nju.edu.cn/adoptium/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | sudo tee /etc/apt/sources.list.d/adoptium.list && \
    sudo apt update && \
    sudo apt install -y temurin-17-jdk temurin-11-jdk temurin-8-jdk
USER ${USER_NAME}

# =========== 配置 jenv =============
RUN git clone https://github.com/jenv/jenv.git ~/.jenv && \
    echo 'export PATH="$HOME/.jenv/bin:$PATH"' >> ~/.zshrc && \
    echo 'eval "$(jenv init -)"' >> ~/.zshrc && \
    source ~/.zshrc && \
    jenv add /usr/lib/jvm/temurin-8-jdk-amd64 && \
    jenv add /usr/lib/jvm/temurin-11-jdk-amd64 && \
    jenv add /usr/lib/jvm/temurin-17-jdk-amd64 && \
    jenv global 11

# =========== 配置 c++ =============
USER root
RUN sudo apt update && sudo apt install -y gcc g++ make cmake gdb
USER ${USER_NAME}

# =========== 配置 gui =============
USER root
RUN sudo apt update && sudo apt install -y x11-apps
USER ${USER_NAME}

# =========== 配置 guifont =============
USER root
COPY src/local.conf /etc/fonts/
COPY src/fonts/* /usr/share/fonts/custom/
RUN sudo fc-cache -f -v
USER ${USER_NAME}

# =========== @deprecated 配置 binfmt（wsl2 中非 Ubuntu 系统会有这个问题，无法启动 systemd）=============


# =========== 配置 常用工具 =============
USER root
RUN sudo apt update && sudo apt install -y rsync iputils-ping bind9-dnsutils htop screen openssh-server && \
    sed -i.bak 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
USER ${USER_NAME}

# =========== 配置 容器卷 =============
VOLUME [ "/mnt/workspace", "/mnt/data" ]


CMD [ "tail", "-f", "/dev/null" ]
