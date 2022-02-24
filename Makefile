#!make
APP_HOST ?= 0.0.0.0
APP_PORT ?= 8080
EXTERNAL_APP_PORT ?= ${APP_PORT}

run = docker-compose \
				run \
				-p ${EXTERNAL_APP_PORT}:${APP_PORT} \
				-e PY_IGNORE_IMPORTMISMATCH=1 \
				-e APP_HOST=${APP_HOST} \
				-e APP_PORT=${APP_PORT} \
				app-mongo

.PHONY: image
image:
	docker-compose build

.PHONY: docker-run
docker-run: image
	$(run)

.PHONY: docker-shell
docker-shell:
	$(run) /bin/bash

.PHONY: test
test:
	$(run) /bin/bash -c 'export && cd /app/stac_fastapi/mongo/tests/ && pytest'

.PHONY: database
database:
	docker-compose run --rm mongo_db

.PHONY: pybase-install
pybase-install:
	pip install wheel && \
	pip install -e ./stac_fastapi/api[dev] && \
	pip install -e ./stac_fastapi/types[dev] && \
	pip install -e ./stac_fastapi/extensions[dev]

.PHONY: install
install: pybase-install
	pip install -e ./stac_fastapi/mongo[dev,server]

.PHONY: ingest
ingest:
	python3 data_loader/data_loader.py