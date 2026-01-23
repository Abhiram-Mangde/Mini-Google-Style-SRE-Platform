FROM python:3.11

WORKDIR /app

COPY webApp/requirements.txt .

RUN pip install  --no-cache-dir -r requirements.txt

COPY webApp/ .

EXPOSE 8080 

CMD ["python", "app.py"]