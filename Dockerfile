FROM rocker/shiny:4.2.2

RUN apt-get update && apt-get install -y \
    libcairo2-dev \
    libgtk2.0-dev xvfb xauth xfonts-base libxt-dev \
    libsodium-dev \
    mysql-client libmysqlclient-dev

RUN rm -rf /srv/shiny-server/*
WORKDIR /srv/shiny-server/
COPY ./ ./

RUN R -f packages_installation.R


CMD ["/init"]
