from fastapi import FastAPI, Request
from llama_cpp import Llama
from sse_starlette import EventSourceResponse

import copy
import asyncio
import requests
import logging

# load the model
print("Loading model...")
llm = Llama(model_path="/home/llama-cpp-user/model/codellama-13b-hf-rust-finetune-full.q5_k_m.gguf")
print("Model loaded!")

app = FastAPI()


@app.get("/")
async def hello():
    return {"hello": "wooooooorld"}


@app.get("/model")
async def model(question: str):
    stream = llm(
        question,
        max_tokens=300,
        stop=["\n", " Q:"],
        echo=True,
    )

    result = copy.deepcopy(stream)
    return {"result": result}


@app.get("/jokes")
async def jokes(request: Request):
    def get_messages():
        url = "https://official-joke-api.appspot.com/random_ten"
        response = requests.get(url)
        if response.status_code == 200:
            jokes = response.json()
            messages = []
            for joke in jokes:
                setup = joke['setup']
                punchline = joke['punchline']
                message = f"{setup} {punchline}"
                messages.append(message)
            return messages
        else:
            return None

    async def sse_event():
        while True:
            if await request.is_disconnected():
                break

            for message in get_messages():
                yield {"data": message}

            await asyncio.sleep(1)

    return EventSourceResponse(sse_event())


@app.get("/llama2")
async def llama(request: Request):
    stream = llm(
        "Question: Who is Ada Lovelace? Answer: ",
        max_tokens=100,
        stop=["\n", " Q:"],
        stream=True,
    )

    async def async_generator():
        for item in stream:
            yield item

    async def server_sent_events():
        async for item in async_generator():
            if await request.is_disconnected():
                break

            result = copy.deepcopy(item)
            text = result["choices"][0]["text"]

            yield {"data": text}

    return EventSourceResponse(server_sent_events())


@app.post("/talk")
async def talk(request: Request):
    request_data = await request.json()

    message = request_data["message"]
    max_tokens = request_data.get("max_tokens", 100)

    logging.info(f"Received request with message: {message}")

    stream = llm(
        message,
        max_tokens=max_tokens,
        stop=["\n", " Q:"],
        stream=True,
    )

    async def async_generator():
        for item in stream:
            yield item

    async def server_sent_events():
        async for item in async_generator():
            if await request.is_disconnected():
                break

            result = copy.deepcopy(item)
            text = result["choices"][0]["text"]

            yield {"data": text}

    return EventSourceResponse(server_sent_events())


@app.post("/llama")
async def llama(request: Request):
    request_data = await request.json()
    message = request_data.get("message", "")

    logging.info(f"Received request with message: {message}")

    responses = llm(
        message,
        max_tokens=100,
        stop=["\n", " Q:"],
        stream=True,
    )

    # Преобразуем словари в строки перед объединением
    responses = [str(response) for response in responses]

    logging.info(f"Responses from llama.cpp: {responses}")

    result = " ".join(responses)  # Собираем все события в одну строку, разделенную пробелами

    return {"response": result}
