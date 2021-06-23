FROM ucsdets/datahub-base-notebook:2021.3.1

USER root

# tensorflow, pytorch stable versions
# https://pytorch.org/get-started/previous-versions/
# https://www.tensorflow.org/install/source#linux

RUN apt-get update && \
	apt-get install -y \
			libtinfo5 \
			nvidia-cuda-toolkit

#RUN conda install cudatoolkit=10.1 \
RUN conda install cudatoolkit=10.2 \
				  cudnn \
				  nccl \
				  -y

# Install pillow<7 due to dependency issue https://github.com/pytorch/vision/issues/1712
RUN pip install --no-cache-dir  datascience \
								PyQt5 \
								scapy \
								nltk \
								opencv-contrib-python-headless \
								jupyter-tensorboard \
								opencv-python \
								pycocotools \
								"pillow<7" \
								tensorflow-gpu>=2.2

# torch must be installed separately since it requires a non-pypi repo. See stable version above
#RUN pip install torch==1.5.0+cu101 torchvision==0.6.0+cu101 pytorch-ignite -f https://download.pytorch.org/whl/torch_stable.html;
RUN conda install pytorch torchvision torchaudio cudatoolkit=10.2 -c pytorch

RUN	chown -R 1000:1000 /home/jovyan

COPY ./tests/ /usr/share/datahub/tests/scipy-ml-notebook
RUN chmod -R +x /usr/share/datahub/tests/scipy-ml-notebook && \
    chown -R 1000:1000 /home/jovyan && \
	chmod +x /run_jupyter.sh

RUN ln -s /usr/local/nvidia/bin/nvidia-smi /opt/conda/bin/nvidia-smi

USER $NB_UID:$NB_GID
ENV PATH=${PATH}:/usr/local/nvidia/bin
