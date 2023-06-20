"""
uvicorn mailer:app --reload
"""
import os
from typing import List

from fastapi import BackgroundTasks, FastAPI
from fastapi_mail import ConnectionConfig, FastMail, MessageSchema, MessageType
from pydantic import BaseModel, EmailStr
from starlette.responses import JSONResponse


TRUTHY = ("True", "1", "t", "y")
MAIL_SUBJECT = os.getenv("MAIL_SUBJECT", "Contact frompersonal.di.works website")
MAIL_USERNAME = os.getenv("MAIL_USERNAME", "")
MAIL_PASSWORD = os.getenv("MAIL_PASSWORD", "")
MAIL_FROM = os.getenv("MAIL_FROM", "contact@di.works")
MAIL_PORT = os.getenv("MAIL_PORT", "1025")
MAIL_SERVER = os.getenv("MAIL_SERVER", "mailhog.default.svc.cluster.local")
MAIL_STARTTLS = os.getenv("MAIL_STARTTLS", "False") in TRUTHY
MAIL_SSL_TLS = os.getenv("MAIL_SSL_TLS", "False") in TRUTHY
USE_CREDENTIALS = os.getenv("USE_CREDENTIALS", "False") in TRUTHY
VALIDATE_CERTS = os.getenv("VALIDATE_CERTS", "False") in TRUTHY


class EmailSchema(BaseModel):
    email: EmailStr
    body: str


conf = ConnectionConfig(
    MAIL_USERNAME = MAIL_USERNAME,
    MAIL_PASSWORD = MAIL_PASSWORD,
    MAIL_FROM = MAIL_FROM,
    MAIL_PORT = MAIL_PORT,
    MAIL_SERVER = MAIL_SERVER,
    MAIL_STARTTLS = MAIL_STARTTLS,
    MAIL_SSL_TLS = MAIL_SSL_TLS,
    USE_CREDENTIALS = USE_CREDENTIALS,
    VALIDATE_CERTS = VALIDATE_CERTS,
)

app = FastAPI()


html = """
<p>Thanks for using Fastapi-mail</p> 
"""


@app.post("/email")
async def simple_send(email: EmailSchema) -> JSONResponse:
    """ @TODO implement csrf here """
    message = MessageSchema(
        subject=MAIL_SUBJECT,
        recipients=[email.dict().get("email")],
        body=email.body,
        subtype=MessageType.html)

    fm = FastMail(conf)
    await fm.send_message(message)
    return JSONResponse(status_code=200, content={"message": "email has been sent"})   