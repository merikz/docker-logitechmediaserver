LMS_VERSION_CHECK_URL="http://www.mysqueezebox.com/update/?version=7.9.2&revision=1&geturl=1&os=debamd64"
LMS_LATEST=$(shell wget -O - -q $(LMS_VERSION_CHECK_URL))
NEWTAG=$(shell echo $(LMS_LATEST) | sed -e s/[^_]*_// | sed -e s/_[^_]*.deb// | sed -e s/~/-/)
OLDTAG=$(shell cat lms_version.txt 2>/dev/null)
REGISTRY_USER=merikz
REPOSITORY=docker-logitechmediaserver
LMS_UID=1000

SHELL=/bin/bash

all: get-lms_version build.status
build: all 
force: _force all

_force:
	-rm lms_version.txt

build.status: lms_version.txt Dockerfile
	echo not finished > build.status
	docker pull debian:jessie
	#replicate hub.docker settings for local build \
	SOURCE_BRANCH=$$(git rev-parse --abbrev-ref HEAD) ; \
	if [ $$SOURCE_BRANCH = "master" ]; then DOCKER_TAG="latest";else DOCKER_TAG=$$SOURCE_BRANCH; fi ; \
	export SOURCE_BRANCH=$$SOURCE_BRANCH ; \
	export DOCKER_TAG=$$DOCKER_TAG ; \
	export LMS_VERSION_CHECK_URL=$(LMS_VERSION_CHECK_URL) ; \
	hooks/build 
	/bin/echo $(NEWTAG) > lms_version.txt
	echo SUCCESS > build.status
	
lms_version.txt: get-lms_version

get-lms_version:
	@if [ -z $(NEWTAG) ];then \
		echo "Failed to get lms version from http://www.mysqueezebox.com/update" >&2 ;\
		exit 1 ;\
	fi ;\
	if [ -n "$(OLDTAG)" ] ;then \
		if [ "$(OLDTAG)" != "$(NEWTAG)" ] ; then \
			echo "New lms available. Old: $(OLDTAG) New:$(NEWTAG)" ;\
			echo $(NEWTAG) > lms_version.txt ;\
		else \
			echo "lms already at version $(NEWTAG). Not building a new one." ;\
		fi ;\
	else \
		echo "Building lms version $(NEWTAG)" ;\
		echo "lms not yet built" > lms_version.txt ;\
	fi

clean:
	[ -e build.status ] && rm build.status || true
	@set -x && \
	containers=`docker ps --quiet \
	  --filter ancestor=$(REGISTRY_USER)/$(REPOSITORY):$(OLDTAG) \
	  --filter ancestor=$(REGISTRY_USER)/$(REPOSITORY):latest` ;\
	[ -z "$$containers" ] || docker stop $$containers 
	@set -x && \
	if [ -e lms_version.txt ]; then \
		docker rmi $(REGISTRY_USER)/$(REPOSITORY):$(OLDTAG) $(REGISTRY_USER)/$(REPOSITORY):latest ;\
		rm lms_version.txt || true ;\
	fi

.PHONY: all get-lms_version force _force clean build
