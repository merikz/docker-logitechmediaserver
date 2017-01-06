LMS_LATEST=$(shell wget -O - -q "http://www.mysqueezebox.com/update/?version=7.9.0&revision=1&geturl=1&os=deb")
NEWTAG=$(shell echo $(LMS_LATEST) | sed -e s/[^_]*_// | sed -e s/_all.deb// | sed -e s/~/-/)
OLDTAG=$(shell cat lms_version.txt 2>/dev/null)
REGISTRY_USER=merikz

SHELL=/bin/bash

all: get-lms_version build.status
build: all 
force: _force all

_force:
	-rm lms_version.txt

build.status: lms_version.txt Dockerfile
	echo not finished > build.status
	docker pull debian:latest
	docker build \
	 --tag $(REGISTRY_USER)/logitechmediaserver:$(NEWTAG) --tag $(REGISTRY_USER)/logitechmediaserver:latest \
	 --build-arg LMS_URL=$(LMS_LATEST) --build-arg LMS_VERSION=$(NEWTAG)  \
	 .
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
	  --filter ancestor=$(REGISTRY_USER)/logitechmediaserver:$(OLDTAG) \
	  --filter ancestor=$(REGISTRY_USER)/logitechmediaserver:latest` ;\
	[ -z "$$containers" ] || docker stop $$containers 
	@set -x && \
	if [ -e lms_version.txt ]; then \
		docker rmi $(REGISTRY_USER)/logitechmediaserver:$(OLDTAG) $(REGISTRY_USER)/logitechmediaserver:latest ;\
		rm lms_version.txt || true ;\
	fi

.PHONY: all get-lms_version force _force clean build