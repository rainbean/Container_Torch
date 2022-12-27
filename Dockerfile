FROM nvidia/cuda:11.1.1-cudnn8-devel-ubuntu20.04 as build

# disable interactive prompt on apt update
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -y update && apt-get install -y unzip

# Download libtorch
ADD https://download.pytorch.org/libtorch/lts/1.8/cu111/libtorch-cxx11-abi-shared-with-deps-1.8.2%2Bcu111.zip libtorch.zip
RUN unzip -q libtorch.zip -d /usr/local

# Download OpenCV
ADD https://github.com/rainbean/build_opencv/releases/download/2022.12.27/opencv-linux.tar.xz opencv-linux.tar.xz
RUN mkdir -p /usr/local/OpenCV && tar xf opencv-linux.tar.xz -C /usr/local/OpenCV

##########################################################

FROM nvidia/cuda:11.1.1-cudnn8-devel-ubuntu20.04
LABEL maintainer "Jimmy Lee"
ENV DEBIAN_FRONTEND=noninteractive

# library
RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential cmake git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --from=build /usr/local/libtorch /usr/local/libtorch
COPY --from=build /usr/local/OpenCV /usr/local/OpenCV
