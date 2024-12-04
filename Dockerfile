FROM ubuntu:latest

LABEL description="An ssh server for JetBrains Gateway with optional public key authentication"

# Default environment variables
ENV SSH_USERNAME=jetbrains
ENV SSH_PASSWORD=jetbrains
ENV SSH_PORT=22
ENV SSH_PUBLIC_KEY=""

RUN apt-get update && apt-get upgrade -y && \
    apt-get install openssh-server git -y && \
    systemctl enable ssh

# Add startup script
COPY startup.sh /startup.sh
RUN chmod +x /startup.sh

VOLUME [ "/opt/home" ]
WORKDIR /opt/home

# Use SSH_PORT environment variable with default
EXPOSE ${SSH_PORT:-22}

CMD ["/startup.sh"]