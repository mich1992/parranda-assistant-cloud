FROM gitpod/workspace-full:latest

# Instalar Docker Compose v2
RUN sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
    && sudo chmod +x /usr/local/bin/docker-compose

# PostgreSQL client
RUN sudo apt-get update && sudo apt-get install -y postgresql-client

# Timezone Colombia
RUN sudo ln -fs /usr/share/zoneinfo/America/Bogota /etc/localtime

USER gitpod
