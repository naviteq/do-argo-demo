FROM python:3.9.12-alpine3.14
COPY src/requirements.txt /usr/src/requirements.txt
RUN pip3 install --no-cache-dir -r /usr/src/requirements.txt
WORKDIR /app
COPY src/app.py .
ENV FLASK_APP=app
ENTRYPOINT [ "flask", "run" ]
