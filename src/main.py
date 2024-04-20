from fastapi import FastAPI, Request, WebSocket
from sse_starlette import EventSourceResponse
from pydantic import BaseModel
from llama_cpp import Llama
import os
import copy
import asyncio

model = "/home/llama-cpp-user/model/" + os.environ.get('MODEL', 'model.gguf')

# n_ctx - длинна контекста: llama(2048, 4096, 8192), llama2(4096; 8192; 16384) где 7,13,40.
llm = Llama(model_path=model, verbose=True, n_ctx=2048)

app = FastAPI()


class LLamaRequest(BaseModel):
    message: str
    max_tokens: str
    temperature: str
    top_p: str
    repeat_penalty: str
    top_k: str


@app.get("/")
async def hello():
    return {"hello": "world"}


@app.post("/talk")
async def ask(request: LLamaRequest):
    message = request.message
    print("Input questions: " + message)

    max_tokens = int(request.max_tokens)
    print("max_tokens: " + str(max_tokens))

    temperature = float(request.temperature)
    print("temperature: " + str(temperature))

    top_p = float(request.top_p)
    print("top_p: " + str(top_p))

    repeat_penalty = float(request.repeat_penalty)
    print("repeat_penalty: " + str(repeat_penalty))

    top_k = int(request.top_k)
    print("top_k: " + str(top_k))

    output = llm(f"Q: {message} A: ",
                 max_tokens=max_tokens,
                 temperature=temperature,
                 top_p=top_p,
                 stop=["Q:", "\n"],
                 echo=True,
                 repeat_penalty=repeat_penalty,
                 top_k=top_k)

    response_text = output.get("choices", [])[0].get("text", "")
    print(response_text)
    return {"response": response_text}
