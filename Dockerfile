FROM nvidia/cuda:10.2-cudnn7-devel-ubuntu18.04 as build

RUN apt-get -y update

# Build tools:
RUN apt-get install -y build-essential cmake unzip

# Parallelism and linear algebra libraries:
RUN apt-get install -y libtbb-dev libeigen3-dev

# Build OpenCV
ADD opencv /workdir
WORKDIR /workdir
RUN cmake -Bbuild -H. \
        -DWITH_EIGEN=ON -DWITH_TBB=ON -DWITH_OPENGL=ON -DBUILD_TIFF=ON \
        -DWITH_QT=OFF -DWITH_FFMPEG=OFF \
        -DBUILD_opencv_apps=OFF -DBUILD_DOCS=OFF -DBUILD_PACKAGE=OFF \
        -DBUILD_PERF_TESTS=OFF -DBUILD_TESTS=OFF -DBUILD_JAVA=OFF \
        -DBUILD_opencv_python2=OFF -DBUILD_opencv_python3=OFF \
        -DBUILD_LIST=imgcodecs,imgproc,highgui \
        -DBUILD_opencv_world=ON \
        -DMAKE_BUILD_TYPE=RELEASE \
        && \
    cd build && \
    make -j4 && \
    make install

# Download libtorch
ADD https://download.pytorch.org/libtorch/cu102/libtorch-cxx11-abi-shared-with-deps-1.7.1.zip libtorch.zip
RUN unzip -q libtorch.zip -d /usr/local

##########################################################

FROM nvidia/cuda:10.2-cudnn7-devel-ubuntu18.04
LABEL maintainer "Jimmy Lee"

# library
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential cmake git \
        libtbb2 libzip-dev \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# opencv
COPY --from=build /usr/local/lib /usr/local/lib
COPY --from=build /usr/local/share/opencv4 /usr/local/share/opencv4
COPY --from=build /usr/local/include/opencv4 /usr/local/include/opencv4 

# libtorch
COPY --from=build /usr/local/libtorch /usr/local/libtorch
