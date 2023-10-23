from fastapi import FastAPI, Request
from llama_cpp import Llama
from sse_starlette import EventSourceResponse
import os
import copy
import asyncio
import requests
import logging

model = "/home/llama-cpp-user/model/" + os.environ.get('MODEL', 'model-q8_0.gguf')
# load the model
print("Loading model...")
llm = Llama(model_path=model)
print("Model loaded!")

app = FastAPI()

# Настройки для Saiga2
# Top-p 0.9
# Top-k 30
# Temperature 0,01


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


@app.post("/talk")
async def ask(request: Request):
    request_data = await request.json()

    message = request_data["message"]
    print("Input questions:" + message)

    max_tokens = request_data.get("max_tokens", 100)
    output = llm(f"Q: {message} A: ",
                 max_tokens=4000,
                 temperature=0.01,
                 top_p=0.9,
                 stop=["Q:", "\n"],
                 echo=False,
                 repeat_penalty=1.1,
                 top_k=30)

    # Extract the relevant information from the output
    response_text = output.get("choices", [])[0].get("text", "")
    print(response_text)
    return {"response": response_text}


@app.get("/llama2")
async def llama(request: Request):
    stream = llm(
        "Question: Who is Ada Lovelace? Answer: ",
        max_tokens=1000,
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