BINARY_NAME=rivenbot-api-service
CONFIG_PATH=config/local.yaml
POSTGRES_USERNAME=username
POSTGRES_PASSWORD=password

export

build:
	go build -o	./bin/$(BINARY_NAME) ./cmd/$(BINARY_NAME)

run: build
	bin/$(BINARY_NAME)

build-image:
	docker build -t rivenbot-api-service:latest .	

compose-run: build-image 
	docker compose up -d

compose-sh: build-image
	docker compose up --build --detach postgres
	docker compose run --rm --entrypoint sh rivenbot-api-service

clean:
	rm -f bin/$(BINARY_NAME)
