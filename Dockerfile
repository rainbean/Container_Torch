FROM nvidia/cuda:10.2-cudnn7-devel-ubuntu18.04 as build

RUN apt-get -y update

# Build tools:
RUN apt-get install -y build-essential cmake unzip

# Parallelism and linear algebra libraries:
RUN apt-get install -y libtbb-dev libeigen3-dev

# Build OpenCV
WORKDIR /build
ARG OPENCV_VERSION='4.2.0'
ADD https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip ${OPENCV_VERSION}.zip
RUN unzip -q ${OPENCV_VERSION}.zip && \
    cd opencv-${OPENCV_VERSION} && \
    cmake -Bbuild -H. \
        -DWITH_QT=OFF -DWITH_OPENGL=ON -DWITH_TBB=ON -DBUILD_TIFF=ON \
        -DBUILD_opencv_apps=OFF -DBUILD_DOCS=OFF -DBUILD_PACKAGE=OFF \
        -DBUILD_PERF_TESTS=OFF -DBUILD_TESTS=OFF \
        -DBUILD_JAVA=OFF -DBUILD_opencv_python2=OFF -DBUILD_opencv_python3=OFF \
        -DBUILD_LIST=imgcodecs,imgproc,highgui \
        -DBUILD_opencv_world=ON \
        -DMAKE_BUILD_TYPE=RELEASE \
        && \
    cd build && \
    make -j4 && \
    make install

# Download libtorch
ADD https://download.pytorch.org/libtorch/cu102/libtorch-cxx11-abi-shared-with-deps-1.5.1.zip libtorch.zip
RUN unzip -q libtorch.zip -d /usr/local

ADD https://download.pytorch.org/libtorch/cpu/libtorch-cxx11-abi-shared-with-deps-1.5.1%2Bcpu.zip libtorch.zip
RUN unzip -q libtorch.zip -d /tmp && \
    mv /tmp/libtorch /usr/local/libtorch_cpu

##########################################################

FROM nvidia/cuda:10.2-cudnn7-devel-ubuntu18.04
LABEL maintainer "Jimmy Lee"

# library
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential cmake git \
        libtbb2 \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# opencv
COPY --from=build /usr/local/lib /usr/local/lib
COPY --from=build /usr/local/share/opencv4 /usr/local/share/opencv4  
COPY --from=build /usr/local/include/opencv4 /usr/local/include/opencv4 

# libtorch
COPY --from=build /usr/local/libtorch /usr/local/libtorch
COPY --from=build /usr/local/libtorch_cpu /usr/local/libtorch_cpu
