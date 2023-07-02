# Dockerfile to deploy a llama-cpp container with conda-ready environments 

# docker pull continuumio/miniconda3:latest

ARG TAG=latest
FROM continuumio/miniconda3:$TAG 

RUN apt-get update \
    && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
        git \
        locales \
        sudo \
        build-essential \
        dpkg-dev \
        wget \
        openssh-server \
        nano \
        software-properties-common \
        python3-venv \
        python3-tk \
        pip \
        bash \
        git \
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

# SSH exposition
EXPOSE 22/tcp
RUN service ssh start

# Create user

RUN groupadd --gid 1020 llama-cpp-group
RUN useradd -rm -d /home/llama-cpp-user -s /bin/bash -G users,sudo,llama-cpp-group -u 1000 llama-cpp-user

# Update user password
RUN echo 'llama-cpp-user:admin' | chpasswd

# Download latest github/llama-cpp in llama.cpp directory and compile it
RUN git clone https://github.com/ggerganov/llama.cpp.git ~/llama.cpp && \
    cd ~/llama.cpp && \
    make

# Install Requirements for python virtualenv
RUN cd ~/llama.cpp && \
    python3 -m pip install -r requirements.txt

# Download model

RUN pip install llama-cpp-python[server]

COPY ./model/wizardLM-7B.ggmlv3.q4_0.bin /home/llama-cpp-user/model/

# Preparing for login
ENV HOME /home/llama-cpp-user
WORKDIR ${HOME}/llama.cpp
USER llama-cpp-user
CMD ["/bin/bash"]

# запуск:
# docker build -t llamaserver .
# docker run -dit --name llamaserver -p 221:22 -p 8000:8000 --gpus all --restart unless-stopped llamaserver:latest
# docker container attach llamaserver
# python3 -m llama_cpp.server --model /home/llama-cpp-user/model/wizardLM-7B.ggmlv3.q4_0.bin
