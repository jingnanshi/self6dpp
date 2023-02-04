docker run -it \
--gpus all \
--shm-size 8G \
--env="DISPLAY=:1" \
--env="CUDA_VISIBLE_DEVICES=0" \
--env="PYTHONPATH=$PYTHONPATH:/opt/project/CASPER-3D/src:/opt/project/CASPER-3D/external/bop_toolkit:/opt/project/CASPER-3D/external:/opt/project/CASPER-3D/experiments" \
--volume="/home/jnshi/code/self6dpp/:/home/appuser/self6dpp" \
--volume="/mnt/jnshi_data/datasets/casper-data:/mnt/datasets/" \
self6d:latest bash

