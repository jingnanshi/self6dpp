# based on dockerfile from detectron2
FROM nvidia/cudagl:11.1.1-devel-ubuntu18.04
# use an older system (18.04) to avoid opencv incompatibility (issue#3524)

ENV DEBIAN_FRONTEND noninteractive

# handle Nvidia Pub key error
RUN rm /etc/apt/sources.list.d/cuda.list
RUN rm /etc/apt/sources.list.d/nvidia-ml.list
RUN apt-key del 7fa2af80
RUN apt-get update && apt-get install -y --no-install-recommends wget
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-keyring_1.0-1_all.deb
RUN dpkg -i cuda-keyring_1.0-1_all.deb

RUN apt-get update && apt-get install -y \
    python3.7 python3.7-dev python3.7-distutils \
    python3-opencv ca-certificates git wget sudo ninja-build

# Make python3 available for python3.7
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 1
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.7 2
RUN update-alternatives --config python3
# Make python available for python3.7
RUN ln -sv /usr/bin/python3.7 /usr/bin/python

RUN apt-get update && apt-get install -y \
	libjpeg-dev zlib1g-dev libopenexr-dev \
	openexr libglfw3-dev libglfw3 libglew-dev libassimp-dev libnuma-dev clang curl autoconf build-essential libtool \
	libeigen3-dev libgoogle-glog-dev libsuitesparse-dev libatlas-base-dev
RUN rm /usr/bin/python && ln -sv /usr/bin/python3 /usr/bin/python

# create a non-root user
ARG USER_ID=1000
RUN useradd -m --no-log-init --system  --uid ${USER_ID} appuser -g sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER appuser
WORKDIR /home/appuser

ENV PATH="/home/appuser/.local/bin:${PATH}"
RUN wget https://bootstrap.pypa.io/pip/get-pip.py && \
	python3.7 get-pip.py --user && \
	rm get-pip.py

# Important! Otherwise, it uses existing numpy from host-modules which throws error
RUN pip install --user numpy==1.20.3

# install dependencies
# See https://pytorch.org/ for other options if you use a different version of CUDA
RUN sudo apt-get install -y libprotobuf-dev protobuf-compiler
RUN pip install --user tensorboard cmake protobuf-compiler   # cmake from apt-get is too old
#RUN pip install --user onnx   # cmake from apt-get is too old
RUN pip install --user torch==1.10 torchvision==0.11.1 -f https://download.pytorch.org/whl/cu111/torch_stable.html

RUN pip install --user 'git+https://github.com/facebookresearch/fvcore'
# install detectron2
RUN git clone https://github.com/facebookresearch/detectron2 detectron2_repo
# set FORCE_CUDA because during `docker build` cuda is not accessible
ENV FORCE_CUDA="1"
# This will by default build detectron2 for all common cuda architectures and take a lot more time,
# because inside `docker build`, there is no way to tell which architecture will be used.
ARG TORCH_CUDA_ARCH_LIST="Kepler;Kepler+Tesla;Maxwell;Maxwell+Tegra;Pascal;Volta;Turing"
ENV TORCH_CUDA_ARCH_LIST="${TORCH_CUDA_ARCH_LIST}"

RUN pip install --user -e detectron2_repo

# Set a fixed model cache directory.
ENV FVCORE_CACHE="/tmp"
# WORKDIR /home/appuser/detectron2_repo

# run detectron2 under user "appuser":
# wget http://images.cocodataset.org/val2017/000000439715.jpg -O input.jpg
# python3 demo/demo.py  \
	#--config-file configs/COCO-InstanceSegmentation/mask_rcnn_R_50_FPN_3x.yaml \
	#--input input.jpg --output outputs/ \
	#--opts MODEL.WEIGHTS detectron2://COCO-InstanceSegmentation/mask_rcnn_R_50_FPN_3x/137849600/model_final_f10217.pkl

# other pip dependencies for self6d
COPY ./requirements.txt /home/appuser 
WORKDIR /home/appuser
RUN pip install -r requirements.txt

# clone self6d
RUN pip install --user Cython
#RUN git clone https://github.com/jingnanshi/self6dpp.git
#RUN cd self6dpp && sh scripts/compile_all.sh