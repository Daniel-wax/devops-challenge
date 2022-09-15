FROM ubuntu:20.04
RUN mkdir /app
WORKDIR /app
RUN apt update && apt install python3 python3-pip -y
COPY . .
RUN ls
RUN pwd
RUN which python3
RUN pip install -r requirements.txt
RUN groupadd -r noroot && useradd --no-log-init -r -g noroot noroot
USER noroot
EXPOSE 5000
ENTRYPOINT ["/usr/bin/python3"]
CMD ["/app/app.py"]
