FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04 as build

RUN apt-get -y update

# Build tools:
RUN apt-get install -y build-essential cmake unzip wget

# GUI (if you want GTK, change 'qt5-default' to 'libgtkglext1-dev' and remove '-DWITH_QT=ON'):
#RUN apt-get install -y qt5-default

# Media I/O:
RUN apt-get install -y zlib1g-dev libjpeg-dev libwebp-dev libpng-dev libtiff5-dev libopenexr-dev

# Parallelism and linear algebra libraries:
RUN apt-get install -y libtbb-dev libeigen3-dev

# Documentation:
RUN apt-get install -y doxygen

# Build OpenCV
WORKDIR /build
ARG OPENCV_VERSION='4.1.0'
RUN wget -q https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip
RUN unzip ${OPENCV_VERSION}.zip && rm ${OPENCV_VERSION}.zip
RUN mv opencv-${OPENCV_VERSION} OpenCV
RUN cd OpenCV && mkdir build && cd build && \
    cmake -DWITH_QT=OFF -DWITH_OPENGL=ON -DWITH_TBB=ON -DBUILD_TIFF=ON \
        -DBUILD_opencv_java=OFF -DBUILD_opencv_python=OFF \
        -DMAKE_BUILD_TYPE=RELEASE \
        .. && \
    make -j4 && \
    make install

##########################################################

FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04
LABEL maintainer "Jimmy Lee"

# library
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential cmake unzip wget git curl \
        libpng16-16 libtiff5 libopenexr22 libwebp6 libgl1 \
        libtbb2 \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# opencv
COPY --from=build /usr/local/lib /usr/local/lib
COPY --from=build /usr/local/share/opencv4 /usr/local/share/opencv4  
COPY --from=build /usr/local/include/opencv4 /usr/local/include/opencv4 

# libtorch
RUN wget -q https://download.pytorch.org/libtorch/cu100/libtorch-cxx11-abi-shared-with-deps-1.2.0.zip -O /tmp/libtorch.zip && \
    unzip /tmp/libtorch.zip -d /usr/local && \
    rm tmp/libtorch.zip
