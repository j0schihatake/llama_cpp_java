from llama_cpp import Llama

# load the model
print("Loading model...")
llm = Llama(model_path="/home/llama-cpp-user/model/vicuna-7b-v1.3-superhot-8k.ggmlv3.q5_K_M.bin")

print("Model loaded!")

stream = llm(
        question,
        max_tokens=300,
        stop=["\n", " Q:"],
        echo=True,
    )


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

class StringResponse:
    def __init__(self):
        self.response = ""

    def append(self, data: str):
        self.response += data + " "

    def get_response(self):
        return self.response.strip()

@app.post("/llama")
async def llama(request: Request):
    request_data = await request.json()
    message = request_data.get("message", "")

    async def async_generator(response: StringResponse):
        # Вызов функции llm и получение всех ответов в список
        responses = llm(
            message,
            max_tokens=300,
            stop=["\n", " Q:"],
            echo=True,
        )
        for item in responses:
            response.append(item)

    async def collect_responses():
        response = StringResponse()
        await async_generator(response)
        return {"response": response.get_response()}

    return await collect_responses()