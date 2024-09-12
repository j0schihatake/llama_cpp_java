ARG TAG=24.1.2-0
FROM continuumio/miniconda3:$TAG

RUN apt-get update \
    && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
        git \
        uvicorn \
        libportaudio2 \
        locales \
        sudo \
        build-essential \
        dpkg-dev \
        ca-certificates \
        netbase\
        tzdata \
        nano \
        software-properties-common \
        python3-venv \
        python3-tk \
        pip \
        bash \
        ncdu \
        net-tools \
        openssh-server \
        libglib2.0-0 \
        libsm6 \
        libgl1 \
        libxrender1 \
        libxext6 \
        ffmpeg \
        wget \
        curl \
        psmisc \
        rsync \
        vim \
        unzip \
        htop \
        pkg-config \
        libcairo2-dev \
        libgoogle-perftools4 libtcmalloc-minimal4  \
    && rm -rf /var/lib/apt/lists/*

# Setting up locales
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8

# Create user
RUN groupadd --gid 1020 ollama-group \
    && useradd -rm -d /home/ollama-user -s /bin/bash -G users,sudo,ollama-group -u 1000 ollama-user \
    && echo 'ollama-user:admin' | chpasswd \
    && mkdir /home/ollama-user/ollama \
    && chmod 777 /home/ollama-user/ollama

# Download and run install script
RUN mkdir /tmp/install \
    && cd /tmp/install \
    && curl -fsSL https://ollama.com/install.sh -o install.sh \
    && sh install.sh \
    && rm -rf /tmp/install

# Preparing for login
ENV HOME /home/ollama-user/ollama/
WORKDIR ${HOME}
USER ollama-user

# Run ollama
#CMD OLLAMA_HOST=0.0.0.0:8085 \
    #&& ollama serve

CMD ollama serve

# Docker
# docker build ollama .

# Официальный образ:
# docker run -d -v ollama:/root/.ollama -p 11434:11434 --name ollama ollama/ollama

# https://lmstudio.ai/
