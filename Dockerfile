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
        ca-certificates \
        netbase\
        tzdata \
        nano \
        software-properties-common \
        python3-venv \
        python3-tk \
        pip \
        bash \
        git \
        ncdu \
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
RUN groupadd --gid 1020 llama-cpp-group
RUN useradd -rm -d /home/llama-cpp-user -s /bin/bash -G users,sudo,llama-cpp-group -u 1000 llama-cpp-user

# Update user password
RUN echo 'llama-cpp-user:admin' | chpasswd

# Download latest github/llama-cpp in llama.cpp directory and compile it
RUN git clone https://github.com/ggerganov/llama.cpp.git ~/llama.cpp && \
    cd ~/llama.cpp && \
    make && \
    git pull

# Install Requirements for llama.cpp
RUN cd ~/llama.cpp && \
    python3 -m pip install -r requirements.txt

RUN pip install llama-cpp-python[server]

RUN pip install pydantic uvicorn[standard] fastapi

RUN mkdir /home/llama-cpp-user/model

RUN mkdir /home/llama-cpp-user/server

RUN mkdir /home/llama-cpp-user/server/src

RUN cd /home/llama-cpp-user/server

ADD src/main.py /home/llama-cpp-user/server/src

ADD requirements.txt /home/llama-cpp-user/server/

RUN cd /home/llama-cpp-user/server && \
   python3 -m pip install -r requirements.txt

RUN cd /home/llama-cpp-user/server/

# Устанавливаем начальную директорию
ENV HOME /home/llama-cpp-user/server
WORKDIR ${HOME}

# Запуск Fast api:
CMD uvicorn src.main:app --host 0.0.0.0 --port 8082 --reload

# запуск:
# в main.py указать имя модели которую собираемся использовать
# docker build -t llamaserver .
# docker run -dit --name llamaserver -p 8082:8082 -v D:/Develop/NeuronNetwork/llama_cpp/llama_cpp_java/model/:/home/llama-cpp-user/model/  --gpus all --restart unless-stopped llamaserver:latest
# или:
# docker run -dit --name llamaserver -p 8082:8082 -v C:/programs/model/:/home/llama-cpp-user/model/  --gpus all --restart unless-stopped llamaserver:latest

# Debug
# docker container attach llamaserver
