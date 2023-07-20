from llama_cpp import Llama

def init():
    # load the model
    print("Loading model...")
    llm = Llama(model_path="/home/llama-cpp-user/model/vicuna-7b-v1.3-superhot-8k.ggmlv3.q5_K_M.bin")
    print("Model loaded!")


def llm(question):
    return llm(
        question,
        max_tokens=300,
        stop=["\n", " Q:"],
        echo=True,
    )