FROM ubuntu:18.04

# Defining Zurich as local timezone
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ="Europe/Zurich"

# Set runtime environment vars (that build the app_config.R in the start.sh file at runtime)
ENV NOMIS_ENV=$NOMIS_ENV
ENV NOMIS_DB_NAME=$NOMIS_DB_NAME
ENV NOMIS_DB_HOSTNAME=$NOMIS_DB_HOSTNAME
ENV NOMIS_DB_PORT=$NOMIS_DB_PORT
ENV NOMIS_DB_USERNAME=$NOMIS_DB_USERNAME
ENV NOMIS_DB_PASSWORD=$NOMIS_DB_PASSWORD

# Update timezone
RUN ln -fs /usr/share/zoneinfo/Europe/Zurich /etc/localtime

# Install system deps alongside cairo, sodium, mysql, mariadb, xml, java and font deps
RUN apt-get update && apt-get install -y tzdata curl lsb-release wget build-essential \
  software-properties-common dirmngr lsb-core \
  libcairo2-dev libxt-dev libgtk2.0-dev xvfb xauth xfonts-base \
  libsodium-dev \
  mysql-client libmysqlclient-dev \
  libmariadb-client-lgpl-dev \
  libxml2-dev openssl libcurl4-openssl-dev libssl-dev gdebi-core \
  openjdk-8-jdk openjdk-8-jre \
  fonts-roboto \
  python3 g++ make python3-pip

# Install R repo
RUN wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
RUN add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/" \
  && apt-get update \
  && apt-get install -y r-base=4.0.3-1.1804.0 r-recommended=4.0.3-1.1804.0 \
  && dpkg-reconfigure -f noninteractive tzdata

# Install required dependencies for building NodeJS, install NodeJS and Terser and add shiny user
RUN curl https://nodejs.org/download/release/v12.18.3/node-v12.18.3-linux-x64.tar.gz | tar -zx -C /usr/local --strip-components=1 \
  && npm install terser@5.3.0 -g \
  && groupadd shiny && useradd -g shiny shiny

# Download and install RShiny
WORKDIR /tmp
RUN wget \
  --no-verbose --show-progress \
  --progress=dot:mega \
  https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-1.5.14.948-amd64.deb \
  && dpkg -i shiny-server-1.5.14.948-amd64.deb \
  && rm shiny-server-1.5.14.948-amd64.deb \
  && R CMD javareconf

# Delete the example application, copy dependency lock file and install R dependencies
RUN rm -rf /srv/shiny-server/*
COPY packages_installation.R renv.lock /srv/shiny-server/
ARG MAKE="make -j2"
WORKDIR /srv/shiny-server/
RUN R -f packages_installation.R

# Copy the rest of the application. Doing it in this order allows changes to the app folder
# without invoking a package rebuild, then build program's assets
COPY ./app/ ./
COPY shiny-server.conf /etc/shiny-server/shiny-server.conf
RUN chown -R shiny:shiny /srv/shiny-server/ \
  && chown -R shiny:shiny /var/lib/shiny-server \
  && R -f assets_compilation.R

# Run as user shiny instead of root and expose the port
USER shiny
EXPOSE 3838

# Build app_config.R file and start application
CMD ["./start.sh"]
