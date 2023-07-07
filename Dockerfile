# Dockerfile to deploy a llama-cpp container with conda-ready environments

# https://github.com/gotzmann/llama.go

FROM golang

RUN git clone https://github.com/qrkourier/sdk-golang.git /app

WORKDIR /app

RUN git clone https://github.com/gotzmann/llama.go.git

RUN go mod tidy

RUN go mod vendor

RUN go build -o llama-go-v1.exe -ldflags "-s -w" main.go

CMD llama-go-v1.4.0-macos \
     --model /home/llama-go-user/model/llama-7b-fp32.bin \
     --server \
     --host 127.0.0.1 \
     --port 8080 \
     --pods 4 \
     --threads 4

# Install Requirements for python virtualenv
#RUN cd ~/llama.go && \
#    python3 -m pip install -r requirements.txt

#RUN pip install llama-cpp-python[server]

#ADD ./run.sh /home/llama-cpp-user/

#RUN cd /home/llama-cpp-user/

# Download model
# COPY ./model/wizardLM-7B.ggmlv3.q4_0.bin /home/llama-cpp-user/model/      --> Так не отработало persmission denied

# Preparing for login
#ENV HOME /home/llama-cpp-user/
#WORKDIR ${HOME}
#USER llama-cpp-user
#CMD ["/bin/bash"]
#CMD ["python", "llama_cpp.server --model /home/llama-cpp-user/model/wizardLM-7B.ggmlv3.q4_0.bin"]

#CMD["/bin/bash", "python3 -m llama_cpp.server --model /home/llama-cpp-user/model/wizardLM-7B.ggmlv3.q4_0.bin"]
#ENTRYPOINT ["/home/llama-cpp-user/run.sh"]

# запуск:
# docker build -t llamaserver .
# docker run -dit --entrypoint /home/llama-cpp-user/run.sh  --name llamaserver -p 8000:8000 -v D:/Develop/NeuronNetwork/llama_cpp/llama_cpp_java/model/wizardLM-7B.ggmlv3.q4_0.bin:/home/llama-cpp-user/model/wizardLM-7B.ggmlv3.q4_0.bin  --gpus all --restart unless-stopped llamaserver:latest
# docker container attach llamaserver
# python3 -m llama_cpp.server --model /home/llama-cpp-user/model/wizardLM-7B.ggmlv3.q4_0.bin

# прочие команды попыток ЗАПУСК С VOLUME MODEL:
# docker run -dit --name llamaserver -p 221:22 -p 8000:8000 --gpus all --restart unless-stopped llamaserver:latest
# docker run --rm -it -dit --name llamaserver -p 8086:8086 -v D:/Develop/NeuronNetwork/llama_cpp/llama_cpp_java/model/wizardLM-7B.ggmlv3.q4_0.bin:/home/llama-cpp-user/model/wizardLM-7B.ggmlv3.q4_0.bin  --gpus all --restart unless-stopped llamaserver:latest
