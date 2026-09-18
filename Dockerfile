FROM python:3.12-slim-bookworm
WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Create non-root user
RUN useradd --create-home appuser
USER appuser

EXPOSE 5000

# Container health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:5000')"

CMD ["python", "app.py"]