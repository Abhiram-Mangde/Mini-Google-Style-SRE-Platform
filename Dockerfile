FROM python:3.11

WORKDIR /app

COPY webApp/requirements.txt .

RUN pip install -r requirements.txt

COPY webApp/ .

EXPOSE 8080 

CMD ["python", "app.py"]