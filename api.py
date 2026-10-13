import ollama
from fastapi import FastAPI, Header, HTTPException
from pydantic import BaseModel

API_KEY = "asjdasfkudbvs@r4$acydjh823794652352abdskasbnda28903476124"
MODEL = "llama3.2:3b"

knowledge = open("1.txt", encoding="utf-8").read()

SYSTEM_PROMPT = f"""You answer on behalf of Milad. Your name is Mishafi Support. Use only the information below.
If the answer isn't there, say you'll pass the question on to Milad.
Keep replies very short and only about the question asked.

INFORMATION:
{knowledge}"""

app = FastAPI()
sessions = {}  # session_id -> message history


class ChatRequest(BaseModel):
    session_id: str
    message: str


@app.post("/chat")
def chat(req: ChatRequest, x_api_key: str = Header(None)):
    if x_api_key != API_KEY:
        raise HTTPException(status_code=401, detail="Invalid API key")

    history = sessions.setdefault(
        req.session_id, [{"role": "system", "content": SYSTEM_PROMPT}]
    )
    history.append({"role": "user", "content": req.message})

    r = ollama.chat(model=MODEL, messages=history)
    answer = r["message"]["content"]
    history.append({"role": "assistant", "content": answer})

    # keep the system prompt plus the last 20 messages so memory doesn't grow forever
    if len(history) > 21:
        sessions[req.session_id] = [history[0]] + history[-20:]

    return {"reply": answer}


@app.post("/reset")
def reset(session_id: str, x_api_key: str = Header(None)):
    if x_api_key != API_KEY:
        raise HTTPException(status_code=401, detail="Invalid API key")
    sessions.pop(session_id, None)
    return {"status": "cleared"}