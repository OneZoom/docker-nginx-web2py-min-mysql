
NAME = onezoom/docker-nginx-web2py-min-mysql
VERSION = 5.7

DEBUG ?= true

DOCKER_USERNAME ?= $(shell read -p "DockerHub Username: " pwd; echo $$pwd)
DOCKER_PASSWORD ?= $(shell stty -echo; read -p "DockerHub Password: " pwd; stty echo; echo $$pwd)
DOCKER_LOGIN ?= $(shell cat ~/.docker/config.json | grep "docker.io" | wc -l)

.PHONY: all build run test stop clean tag_latest release clean_images

all: build

docker_login:
ifeq ($(DOCKER_LOGIN), 1)
		@echo "Already login to DockerHub"
else
		@docker login -u $(DOCKER_USERNAME) -p $(DOCKER_PASSWORD)
endif

build:
	docker build \
		--build-arg MYSQL_VERSION=$(VERSION) \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg DEBUG=$(DEBUG) \
		-t $(NAME):$(VERSION) --rm .

run:
	@if ! docker images $(NAME) | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME) version $(VERSION) is not yet built. Please run 'make build'"; false; fi

	rm -rf /tmp/mysql
	mkdir -p /tmp/mysql/etc
	mkdir -p /tmp/mysql/lib

	docker run -d \
		-e MYSQL_DATABASE=mydb \
		-e MYSQL_USERNAME=user \
		-e MYSQL_PASSWORD=pass \
		-v /tmp/mysql/etc:/etc/mysql/conf.d \
		-v /tmp/mysql/lib:/var/lib/mysql \
		-e DEBUG=$(DEBUG) \
		--name mysql $(NAME):$(VERSION)

	sleep 2

	docker run -d \
		-e DISABLE_MYSQL=1 \
		-e DEBUG=$(DEBUG) \
		--name mysql_no_mysql $(NAME):$(VERSION)

	sleep 1

	docker run -d \
		-e DEBUG=$(DEBUG) \
		--name mysql_default $(NAME):$(VERSION)

	sleep 4

test:
	sleep 10
	./bats/bin/bats test/tests.bats

stop:
	docker exec mysql /bin/bash -c "sv stop mysql" 2> /dev/null || true
	sleep 2
	docker exec mysql /bin/bash -c "rm -rf /etc/mysql/conf.d/*" 2> /dev/null || true
	docker exec mysql /bin/bash -c "rm -rf /var/lib/mysql//*" 2> /dev/null || true
	docker stop mysql mysql_no_mysql mysql_default 2> /dev/null || true

clean: stop
	docker rm mysql mysql_no_mysql mysql_default 2> /dev/null || true
	rm -rf /tmp/mysql || true
	docker images | grep "<none>" | awk '{print$3 }' | xargs docker rmi 2> /dev/null || true

publish: docker_login run test clean
	docker push $(NAME)

tag_latest:
	docker tag $(NAME):$(VERSION) $(NAME):latest

release: docker_login  run test clean tag_latest
	docker push $(NAME)

clean_images: clean
	docker rmi $(NAME):latest $(NAME):$(VERSION) 2> /dev/null || true
	docker logout 


