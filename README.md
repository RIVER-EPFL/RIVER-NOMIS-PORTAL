# NOMIS Portal

This Shiny app is meant to provide an easy interface for the NOMIS researchers to interact with their data. It can also be used as a data sharing portal accessible via the Web if wanted.

## Dependencies

Core dependencies and installation steps are defined in the `Dockerfile` assuming a Ubuntu installation.

- R version 4.2.2
- Node.js (tested version: 12.18.3)
- Terser.js (tested version: 5.3.0)

R packages versions are defined in `packages_installation_fixedversions.R`.

## Getting started

The service can be run locally or within a Docker environment. It requires a MySQL/MariaDB database to support it, and therefore requires the credentials of such a database to exist by supplying environment variables

### Docker Compose

Using the supplied `docker-compose.yml` file, a nomis portal, mariadb database and Traefik reverse proxy will start, simulating a complete deployment. From the root of the repository, and with Docker and Docker compose set-up, type:

```bash
docker compose up --build
```

By default, the reverse proxy will start on http port 80, and listen for connections to http://nomis.local. Add this hostname as a new line to your `/etc/hosts` system file, addressing your machine's local IP (`127.0.0.1`).

```bash
# Static table lookup for hostnames.

127.0.0.1 nomis.local
```

You should be able to access the site at [http://nomis.local](http://nomis.local).

### Docker (build and run)

With the supplied `Dockerfile`, and from the root of the repository, build the image with:

```bash
docker build -t nomis-portal .
```

Then run the container, suppylying the MariaDB database to connect to with the environment variables and exposing port 3838.

The environment variables are as follows:

```
NOMIS_ENV           // Whether the application is in `production` or `development`
NOMIS_DB_NAME       // The name of the database in MariaDB
NOMIS_DB_HOSTNAME   // The hostname of the MariaDB server
NOMIS_DB_PORT       // The port of the MariaDB server
NOMIS_DB_USERNAME   // The username the portal uses to access MariaDB
NOMIS_DB_PASSWORD   // The passworrd the portal uses to access MariaDB
```

### Ubuntu

The `Dockerfile` is built upon a Ubuntu image, therefore the installation steps for all dependencies can be follow from the instructions defined within.

#### R and Rstudio
You need to install R and we recommend to use Rstudio as well. You can get the latest version of R or the recommend version forthis app on the CRAN website https://cran.r-project.org/ and Rstutio from their website https://rstudio.com/products/rstudio/download/.

#### Node and Terser
To be able to parse and minify the cusom JavaScript files you will need to install Node.js and Terser.js as well.

To install Node please refer yourself to the documentation https://nodejs.org/en/download/.

Terser.js will need to be install globally to be accessible by the app. Once Node is installed run the following command:
```sh
npm install terser -g
```

## App organisation

### App.R
The main app script is the `App.R` file. It contains the basic app structure and logic to create and operate the main tabs and the initialization tasks.

### Modules
The app is organized and subdivised by tabs. Each tab and sub-tab is contained in a isolated module present in the `modules` directory. The structure of the `modules` directory should mirror the app structure. Some other reusable shiny components that aren't tabs or sub-tabs, but require both an UI and a server function, are also containerized in modules and located in a relevant place of the directory structure of the `modules` directory.

### Utils
Some reusable functions are organized by functionality in different files located in the `utils` directory.

| File                    | Description |
|:----------------------- |:----------- |
| dataframe_generator.R | Contains all the functions necessary for generating displayable dataframe in rhandsontable. |
| helper_database.R    | Contains all the functions used for interaction with the SQL database. |
| helper_dataframe.R        | Contains the functions used to process dataframe. |
| helper_download.R      | Contains all the functions for the download part of the Shiny App. |
| helper_expedition.R    | Contains the functions used to create ggplots. |
| helper_file.R    | Contains the functions used to manipulate files. |
| helper_functions.R    | Contains all the functions that does not fit in other files. |
| helper_log.R    | Contains all the functions to handle log. |
| helper_visualisation.R    | Contains functions used for visualisation. |
| shiny_extensions.R      | Contains the functions that extend _Shiny_ functionalities. |
| template_config.R    | Contains all the configuration informations. |

### Assets
The custom stylesheet in _SCSS_ format and _JavaScript_ are located in the `sass` and `js` directories, respectively. These directories are located in the `assets` directory.

During development, both _SCSS_ and _JavaScript_ files are compiled and minified in two files, `main.css` and `nomisportal.js`, which are saved in the `www` directory.

To deploy the app in **production**, the assets **must be compiled manually** by running the `assets_compilation.R` script file from the app folder.

#### _SCSS_
In the `sass` directory, the `main.scss` file is an index that is used to load in the correct order all the partial files organized in different thematic directories.

#### _JavaScript_
The `js` directory contains all the _JavaScript_ code organized in different files by functionnality. The `manifest.json` file is used to compile the files together in a predefined order.

### Other _R_ script files

#### app_config.R
A `app_config.R` file **is required** and should contains all sensible information, such as DB name or password. These information are saved in environment variables when the file is sourced during the app startup. More info at https://github.com/ninojeannet/SBER-NOMIS-PORTAL/wiki/Deployment

**Note**: In a Docker deployment, environment variables are used. Refer to the Docker usage instructions.

#### packages_installation.R
The `packages_installation.R` file contains instructions to install the _R_ packages with the correct version. To install them, just run the script file.

### Other directories

#### HTML components
The `html_components` directory contains all the HTML template used in the app.

#### www
The `www` directory is the public directory of the _Shiny_ app in which all the publicly accessible ressources must be put, such as favicon, images or assets.

#### Data
The `data` directory contains all the files saved from the application on the server.

#### DB backups
The `db_backups` directory **should be present** and will contains all the _SQL_ database backups made with the DB backup functionnality of the portal actions module. See `modules/portal_management/portal_actions.R` file for more information.

## App deployment
Detail information on how to deploy this app on an _Ubuntu_ server can be found here: https://github.com/ninojeannet/SBER-NOMIS-PORTAL/wiki/Deployment

Please check out the official wiki for more informations about the application (https://github.com/ninojeannet/SBER-NOMIS-PORTAL/wiki/)
