FROM python:3.9-slim

RUN useradd -m appuser

WORKDIR /app

RUN chown -R appuser:appuser /app

COPY requirements.txt requirements.txt

USER appuser

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

ENV PULL_INTERVAL=5

CMD ["python", "app.py"]