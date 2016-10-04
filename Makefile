
NAME = madharjan/docker-mysql
VERSION = 5.5

.PHONY: all build run tests clean tag_latest release clean_images

all: build

build:
	docker build \
		--build-arg MYSQL_VERSION=$(VERSION) \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg DEBUG=true \
		-t $(NAME):$(VERSION) --rm .

run:
	rm -rf /tmp/mysql
	mkdir -p /tmp/mysql/etc
	mkdir -p /tmp/mysql/lib

	docker run -d \
		-e MYSQL_DATABASE=mydb \
		-e MYSQL_USERNAME=user \
		-e MYSQL_PASSWORD=pass \
		-v /tmp/mysql/etc:/etc/mysql/conf.d \
		-v /tmp/mysql/lib:/var/lib/mysql \
		-e DEBUG=true \
		--name mysql $(NAME):$(VERSION)

	sleep 2

	docker run -d \
		-e DISABLE_MYSQL=1 \
		-e DEBUG=true \
		--name mysql_no_mysql $(NAME):$(VERSION)

	sleep 1

	docker run -d \
		-e DEBUG=true \
		--name mysql_default $(NAME):$(VERSION)

	sleep 3

tests:
	sleep 3
	./bats/bin/bats test/tests.bats

clean:
	docker exec mysql /bin/bash -c "sv stop mysql" || true
	sleep 2
	docker exec mysql /bin/bash -c "rm -rf /etc/mysql/conf.d/*" || true
	docker exec mysql /bin/bash -c "rm -rf /var/lib/mysql//*" || true
	docker stop mysql mysql_no_mysql mysql_default || true
	docker rm mysql mysql_no_mysql mysql_default || true
	rm -rf /tmp/mysql || true

tag_latest:
	docker tag $(NAME):$(VERSION) $(NAME):latest

release: run tests clean tag_latest
	@if ! docker images $(NAME) | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME) version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@if ! head -n 1 Changelog.md | grep -q 'release date'; then echo 'Please note the release date in Changelog.md.' && false; fi
	docker push $(NAME)
	@echo "*** Don't forget to create a tag. git tag $(VERSION) && git push origin $(VERSION) ***"
	curl -X https://hooks.microbadger.com/images/madharjan/docker-mysql/fvNsVmJPHGNMhZSH-XYz2Klt1gE=

clean_images:
	docker rmi $(NAME):latest $(NAME):$(VERSION) || true
