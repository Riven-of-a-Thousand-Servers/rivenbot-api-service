BINARY_NAME=rivenbot-api-service
ENV_FILE=config/local.yaml
POSTGRES_USERNAME=username
POSTGRES_PASSWORD=password

export

build:
	go build -o	./bin/$(BINARY_NAME) ./cmd/$(BINARY_NAME)

run: build
	bin/$(BINARY_NAME)

clean:
	rm -f bin/$(BINARY_NAME)
