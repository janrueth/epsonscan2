MAINTAINER="Jan Rüth"
CONTACT="epsonscan2@djiehmail.com"
VERSION=6.7.43.0-1
FILE=epsonscan2-${VERSION}.src.tar.gz
PACKAGEVERSION_MAJOR=0
PACKAGEVERSION_MINOR=1
# we keep the original version as a suffix
PACKAGEVERSION_PATCH=0-${VERSION}

.PHONY: clean
clean:
	rm -rf epsonscan2/
	rm -rf artifacts/
	rm ${FILE}

artifacts:
	mkdir -p artifacts

epsonscan2:
ifeq ("$(wildcard $(FILE))", "")
	wget https://support.epson.net/linux/src/scanner/epsonscan2/${FILE}
endif
	mkdir -p epsonscan2
	tar -xzf ${FILE} --strip-components=1 -C epsonscan2

.PHONY: patch
patch: epsonscan2
	cd patches && ./apply.sh

.PHONY: prepare
prepare: artifacts epsonscan2 patch

.PHONY: install-deps
install-deps:
	cd epsonscan2 && apt-get --quiet update && ./install-deps

.PHONY: docker-full
docker-full: prepare
	docker build . -t epson-builder
	docker run -v $(shell pwd):/build epson-builder make full

.PHONY: full
full:
	mkdir -p epsonscan2/build
	cd epsonscan2/build && \
	    EPSON_VERSION=1 cmake .. \
			-DHEADLESS=OFF \
			-DEPSON_VERSION="-${VERSION}" \
			-DCPACK_DEBIAN_PACKAGE_SHLIBDEPS=YES \
			-DCPACK_PACKAGE_CONTACT=${CONTACT} \
			-DCPACK_DEBIAN_PACKAGE_MAINTAINER=${MAINTAINER} \
			-DCPACK_PACKAGE_VERSION_MAJOR=${PACKAGEVERSION_MAJOR} \
			-DCPACK_PACKAGE_VERSION_MINOR=${PACKAGEVERSION_MINOR} \
			-DCPACK_PACKAGE_VERSION_PATCH=${PACKAGEVERSION_PATCH} \
			-DCPACK_DEBIAN_FILE_NAME="DEB-DEFAULT" \
			-DCPACK_RESOURCE_FILE_LICENSE="../LICENSE" \
			-DCPACK_RESOURCE_FILE_README="../README" \
			-DCPACK_OUTPUT_FILE_PREFIX="../../artifacts" \
		&& \
	    make -j2 && \
		cpack -G DEB

.PHONY: docker-headless
docker-headless: prepare
	docker build . -t epson-builder
	docker run -v $(shell pwd):/build epson-builder make headless

.PHONY: headless
headless:
	mkdir -p epsonscan2/build
	cd epsonscan2/build && \
	    EPSON_VERSION=1 cmake .. \
			-DHEADLESS=ON \
			-DCPACK_DEBIAN_PACKAGE_REPLACES="epsonscan2" \
			-DCPACK_DEBIAN_PACKAGE_CONFLICTS="epsonscan2" \
			-DCPACK_DEBIAN_PACKAGE_PROVIDES="epsonscan2" \
			-DEPSON_VERSION="-${VERSION}" \
			-DCPACK_DEBIAN_PACKAGE_SHLIBDEPS=YES \
			-DCPACK_PACKAGE_CONTACT=${CONTACT} \
			-DCPACK_DEBIAN_PACKAGE_MAINTAINER=${MAINTAINER} \
			-DCPACK_PACKAGE_VERSION_MAJOR=${PACKAGEVERSION_MAJOR} \
			-DCPACK_PACKAGE_VERSION_MINOR=${PACKAGEVERSION_MINOR} \
			-DCPACK_PACKAGE_VERSION_PATCH=${PACKAGEVERSION_PATCH} \
			-DCPACK_DEBIAN_FILE_NAME="DEB-DEFAULT" \
			-DCPACK_RESOURCE_FILE_LICENSE="../LICENSE" \
			-DCPACK_RESOURCE_FILE_README="../README" \
			-DCPACK_OUTPUT_FILE_PREFIX="../../artifacts" \
		&& \
	    make -j2 && \
		cpack -G DEB

.PHONY: all
all: headless full

.PHONY: docker-all
docker-all: docker-headless docker-full
