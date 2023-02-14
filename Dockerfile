# FROM rocker/shiny:4.2.2
#
# RUN apt-get update && apt-get install -y \
#     libcairo2-dev \
#     libgtk2.0-dev xvfb xauth xfonts-base libxt-dev \
#     libsodium-dev \
#     mysql-client libmysqlclient-dev
#
# RUN rm -rf /srv/shiny-server/*
# WORKDIR /srv/shiny-server/
# COPY ./ ./
#
# RUN R -f packages_installation.R
#
#
# CMD ["/init"]


# Ubuntu 18.04.6 LTS

FROM ubuntu:18.04

# Install necessary dependencies for the R repository
RUN apt-get update && apt-get install -y \
    curl lsb-release wget

# Add repository
RUN apt-get install -y --no-install-recommends software-properties-common dirmngr
RUN wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
RUN add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"

# Install tzdata, defining Zurich as local timezone
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ="Europe/Zurich"
RUN ln -fs /usr/share/zoneinfo/Europe/Zurich /etc/localtime
RUN apt-get -y install tzdata
RUN dpkg-reconfigure -f noninteractive tzdata

# Install R version 4.0.3
RUN apt-get install -y r-base=4.0.3-1.1804.0 r-recommended=4.0.3-1.1804.0

# Install required dependencies for building NodeJS
RUN apt-get install -y python3 g++ make python3-pip

# Install NodeJS
RUN curl https://nodejs.org/download/release/v12.18.3/node-v12.18.3-linux-x64.tar.gz | tar -zx -C /usr/local --strip-components=1

# Install Terser globally
RUN npm install terser@5.3.0 -g

# Install cairo and dependencies
RUN apt-get install -y libcairo2-dev libxt-dev libgtk2.0-dev xvfb xauth xfonts-base

# Install sodium dependencies
RUN apt-get install -y libsodium-dev

# Install MySQL dependencies
RUN apt-get install -y mysql-client libmysqlclient-dev

# Install XML dependencies
RUN apt-get install -y libxml2-dev openssl libcurl4-openssl-dev

# Copy nomis directory and install R dependencies
WORKDIR /
COPY app /app
COPY packages_installation_fixedversions.R /app

WORKDIR /app
ARG MAKE="make -j12"

# # Set environment variables for R application by creating app_config.R
# ENV NOMIS_ENV=production
# ENV NOMIS_DB_NAME=db_name
# ENV NOMIS_DB_HOSTNAME=host_address
# ENV NOMIS_DB_PORT=3306
# ENV NOMIS_DB_USERNAME=username
# ENV NOMIS_DB_PASSWORD=password

# Install packages from fixed versions
RUN R -f packages_installation_fixedversions.R

# Compile the RShiny environment
RUN R -f assets_compilation.R

ENTRYPOINT ["R", "-f", "app.R"]
