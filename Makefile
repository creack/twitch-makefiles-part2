NAME  = svc
SRCS  = $(shell find . -name '*.go') .dockerignore Dockerfile
DB_C  = pq
DB_IP = $(shell cat .wait_db)

.PHONY: all
all: start

.build_svc: ${SRCS}
	docker build -t ${NAME} .
	@touch $@

.start_db:
	docker run --rm -d --name ${DB_C} -e POSTGRES_PASSWORD=password postgres:latest
	@touch $@

.wait_db: .start_db
	@until docker run --rm --link ${DB_C} postgres psql "postgres://postgres:password@pq:5432?sslmode=disable" -c 'SELECT NOW()' > /dev/null 2> /dev/null; do sleep 1; echo "Waiting for db to be ready" >&2; done
	@docker inspect -f '{{.NetworkSettings.IPAddress}}' ${DB_C} > $@
	@echo "DB Ready!" >&2


.PHONY: clean
clean:
	rm -f .build_svc .start_db .wait_db
	@docker rm -f -v ${DB_C} > /dev/null 2> /dev/null || true

.PHONY: re
re: clean all

.PHONY: start
start: .build_svc .wait_db
	 docker run --rm --name svc -e DB_IP=${DB_IP} ${NAME}

.PHONY: test
test: .build_svc .wait_db
	 docker run --rm --name svc -e DB_IP=${DB_IP} ${NAME} go test -v
