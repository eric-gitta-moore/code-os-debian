ARG IMAGE_NAME=nvidia/cuda:11.8.0-base-ubuntu22.04
FROM ${IMAGE_NAME} AS base

# 使用原地址 GITCLONE_MIIOR=
ARG GITCLONE_MIRROR=https://ghproxy.com/

ARG USER_PWD=linux \
    USER_NAME=linux \
    CONDA_INSTALLER_URL=https://mirror.nju.edu.cn/anaconda/miniconda/Miniconda3-py39_23.5.2-0-Linux-x86_64.sh \
    NVM_INSTALLER_URL=${GITCLONE_MIRROR}https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh \ 
    NVM_NODEJS_ORG_MIRROR=https://npmmirror.com/mirrors/node/ \
    NVM_SOURCE=${GITCLONE_MIRROR}https://github.com/nvm-sh/nvm.git

ARG DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-c"]
ENV SHELL=/bin/bash
USER root

# =========== 换源 =============
RUN sed -i.bak 's#archive.ubuntu.com#mirror.nju.edu.cn#g' /etc/apt/sources.list && \
    sed -i 's#security.ubuntu.com#mirror.nju.edu.cn#g' /etc/apt/sources.list && \
    apt update

# =========== 配置 zsh =============

RUN apt update && \
    apt install git curl wget zsh sudo vim lua5.2 -y

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
RUN echo 'Y' | sh -c "$(curl -fsSL ${GITCLONE_MIRROR}https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
    git clone ${GITCLONE_MIRROR}https://github.com/skywind3000/z.lua.git ~/z.lua && \
    git clone ${GITCLONE_MIRROR}https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
    git clone ${GITCLONE_MIRROR}https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && \
    git clone --depth=1 ${GITCLONE_MIRROR}https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k && \
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

# =========== 配置 常用工具 =============
USER root
RUN sudo apt update && \
    sudo apt install -y \ 
    rsync iputils-ping bind9-dnsutils htop screen openssh-server tree && \
    sed -i.bak 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
USER ${USER_NAME}

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

# =========== 配置 conda =============
RUN wget -O ~/conda.sh ${CONDA_INSTALLER_URL} && \
    sh ~/conda.sh -b && \
    eval "$(~/miniconda3/bin/conda shell.zsh hook)" && \
    conda init zsh && \
    cat <<'EOF' > ~/.condarc
channels:
  - defaults
show_channel_urls: true
default_channels:
  - https://mirror.nju.edu.cn/anaconda/pkgs/main
  - https://mirror.nju.edu.cn/anaconda/pkgs/r
  - https://mirror.nju.edu.cn/anaconda/pkgs/msys2
custom_channels:
  conda-forge: https://mirror.nju.edu.cn/anaconda/cloud
  pytorch: https://mirror.nju.edu.cn/anaconda/cloud
  nvidia: https://mirrors.cernet.edu.cn/anaconda-extra/cloud
EOF

# pdm
RUN source ~/.zshrc && \
    curl -sSL https://pdm.fming.dev/install-pdm.py | python3 - && \
    echo '\n\nexport PATH=$HOME/.local/bin:$PATH' >> ~/.zshrc && \
    source ~/.zshrc && \
    pdm config pypi.url https://mirror.nju.edu.cn/pypi/web/simple && \
    pip config set global.index-url https://mirror.nju.edu.cn/pypi/web/simple

# =========== 配置 nvm =============
RUN curl -o- ${NVM_INSTALLER_URL} | bash && \
    source ~/.zshrc && \
    nvm install --lts && \
    nvm install 16 && \
    nvm install 14 && \
    nvm install 10 && \
    nvm use 16 && \
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
RUN git clone ${GITCLONE_MIRROR}https://github.com/jenv/jenv.git ~/.jenv && \
    echo 'export PATH="$HOME/.jenv/bin:$PATH"' >> ~/.zshrc && \
    echo 'eval "$(jenv init -)"' >> ~/.zshrc && \
    source ~/.zshrc && \
    jenv add /usr/lib/jvm/temurin-8-jdk-amd64 && \
    jenv add /usr/lib/jvm/temurin-11-jdk-amd64 && \
    jenv add /usr/lib/jvm/temurin-17-jdk-amd64 && \
    jenv global 11


# =========== @deprecated 配置 binfmt（wsl2 中非 Ubuntu 系统会有这个问题，无法启动 systemd）=============

# =========== 配置 TensorFlow for python==3.9 =============
# RUN source ~/.zshrc && \
# conda install -c conda-forge cudatoolkit=11.8.0 && \
# python3 -m pip install nvidia-cudnn-cu11==8.6.0.163 tensorflow==2.13 && \
# mkdir -p $CONDA_PREFIX/etc/conda/activate.d && \
# echo 'CUDNN_PATH=$(dirname $(python -c "import nvidia.cudnn;print(nvidia.cudnn.__file__)"))' >> $CONDA_PREFIX/etc/conda/activate.d/env_vars.sh && \
# echo 'export LD_LIBRARY_PATH=$CONDA_PREFIX/lib/:$CUDNN_PATH/lib:$LD_LIBRARY_PATH' >> $CONDA_PREFIX/etc/conda/activate.d/env_vars.sh && \
# source $CONDA_PREFIX/etc/conda/activate.d/env_vars.sh && \
# mv $CONDA_PREFIX/lib/libtinfo.so.6 $CONDA_PREFIX/lib/libtinfo.so.6.bak # 临时解决报错：lib/libtinfo.so.6: no version information available (required by bash)

# =========== 配置 pytorch =============
RUN source ~/.zshrc && \
    conda install pytorch torchvision torchaudio pytorch-cuda=11.8 -c pytorch -c nvidia -y

# =========== 配置 docker =============
USER root
RUN sudo apt-get update && sudo apt-get install -y ca-certificates curl gnupg && \
    sudo install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    sudo chmod a+r /etc/apt/keyrings/docker.gpg && \
    echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://mirror.nju.edu.cn/docker-ce/linux/debian \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    sudo apt-get update && \
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
USER ${USER_NAME}


# =========== 配置 容器卷 =============
VOLUME [ "/mnt/workspace", "/mnt/data" ]


CMD [ "tail", "-f", "/dev/null" ]
