FROM python:3.9-slim

RUN useradd -m appuser

WORKDIR /app

RUN chown -R appuser:appuser /app

COPY requirements.txt /app/requirements.txt

USER appuser

RUN pip install --no-cache-dir -r /app/requirements.txt

COPY . .

EXPOSE 5000

CMD ["python", "app.py"]