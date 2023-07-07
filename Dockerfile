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

# Добавил из готового примера:
ENV HOST=0.0.0.0
#EXPOSE 8086
#ENV PATH=/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
#ENV GPG_KEY=A035C8C19219BA821ECEA86B64E628F8D684696D
#ENV PYTHON_VERSION=3.11.3

#RUN service ssh start

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

RUN pip install llama-cpp-python[server]

RUN mkdir /home/llama-cpp-user/model

ADD ./run.sh /home/llama-cpp-user/

RUN cd /home/llama-cpp-user/

# Download model
# COPY ./model/wizardLM-7B.ggmlv3.q4_0.bin /home/llama-cpp-user/model/      --> Так не отработало persmission denied

# Preparing for login
#ENV HOME /home/llama-cpp-user/
#WORKDIR ${HOME}
#USER llama-cpp-user
#CMD ["/bin/bash"]
#CMD ["python", "llama_cpp.server --model /home/llama-cpp-user/model/wizardLM-7B.ggmlv3.q4_0.bin"]

#CMD["/bin/bash", "python3 -m llama_cpp.server --model /home/llama-cpp-user/model/wizardLM-7B.ggmlv3.q4_0.bin"]
ENTRYPOINT ["/home/llama-cpp-user/run.sh"]

# запуск:
# docker build -t llamaserver .
# docker run -dit --entrypoint /home/llama-cpp-user/run.sh  --name llamaserver -p 8000:8000 -v D:/Develop/NeuronNetwork/llama_cpp/llama_cpp_java/model/wizardLM-7B.ggmlv3.q4_0.bin:/home/llama-cpp-user/model/wizardLM-7B.ggmlv3.q4_0.bin  --gpus all --restart unless-stopped llamaserver:latest
# docker container attach llamaserver
# python3 -m llama_cpp.server --model /home/llama-cpp-user/model/wizardLM-7B.ggmlv3.q4_0.bin

# прочие команды попыток ЗАПУСК С VOLUME MODEL:
# docker run -dit --name llamaserver -p 221:22 -p 8000:8000 --gpus all --restart unless-stopped llamaserver:latest
# docker run --rm -it -dit --name llamaserver -p 8086:8086 -v D:/Develop/NeuronNetwork/llama_cpp/llama_cpp_java/model/wizardLM-7B.ggmlv3.q4_0.bin:/home/llama-cpp-user/model/wizardLM-7B.ggmlv3.q4_0.bin  --gpus all --restart unless-stopped llamaserver:latest
