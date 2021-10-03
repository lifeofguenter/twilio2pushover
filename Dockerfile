FROM python:3.9-alpine

EXPOSE 8000

ENTRYPOINT ["waitress-serve"]
CMD ["--listen=*:8000", "app:app"]

WORKDIR /app

COPY requirements.txt .

RUN pip install -r requirements.txt

COPY . .
