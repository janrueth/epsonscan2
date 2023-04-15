FROM debian:bullseye

COPY ./epsonscan2/install-deps .

RUN apt-get --quiet update \
    && apt-get install -y cmake file && DEBIAN_FRONTEND=noninteractive \
    ./install-deps

WORKDIR /build
CMD ["/bin/bash"]
