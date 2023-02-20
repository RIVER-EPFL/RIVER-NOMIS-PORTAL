APPLICATION_NAME ?= nomis-data-portal
 
build:
	docker build --tag ${APPLICATION_NAME} .
run:
	docker compose up 

