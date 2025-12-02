
FROM python:3.11-slim
WORKDIR /app
COPY . /app
RUN python -m pip install --upgrade pip && pip install -r requirements.txt
ENV FLASK_APP=app
ENV TUTOR_TOKEN=demo-token
CMD ["gunicorn", "-b", "0.0.0.0:8000", "app:app"]
