FROM ucsdets/datahub-base-notebook:2021.3.1

USER root

# tensorflow, pytorch stable versions
# https://pytorch.org/get-started/previous-versions/
# https://www.tensorflow.org/install/source#linux

RUN apt-get update && \
	apt-get install -y \
			libtinfo5 
#			nvidia-cuda-toolkit

RUN apt-get install -y apt-utils
RUN apt-get install -y libglew-dev 
RUN apt-get install -y patchelf
RUN apt-get install -y libosmesa6-dev libgl1-mesa-glx libglfw3
#			nvidia-cuda-toolkit

#RUN conda install cudatoolkit=10.2 \
#RUN conda install cudatoolkit=10.1 \
#				  cudatoolkit-dev=10.1\
#				  cudnn=7.6.5 \
RUN conda install pytorch torchvision torchaudio cudatoolkit=11.2 -c pytorch
RUN conda install cudatoolkit=11.2 \
				  cudnn=8.1.0 \
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
								tensorflow-gpu==2.6 \
								gym==0.10.5 \
								mujoco-py==1.50.1.56

RUN	chown -R 1000:1000 /home/jovyan

COPY ./tests/ /usr/share/datahub/tests/scipy-ml-notebook
RUN chmod -R +x /usr/share/datahub/tests/scipy-ml-notebook && \
    chown -R 1000:1000 /home/jovyan && \
	chmod +x /run_jupyter.sh

RUN ln -s /usr/local/nvidia/bin/nvidia-smi /opt/conda/bin/nvidia-smi

RUN echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/jovyan/.mujoco/mjpro150/bin' >> ~/.bashrc
RUN chmod -R 777 /opt/conda/lib/python3.8/site-packages/mujoco_py/

RUN mkdir ~/.mujoco
RUN cd ~/.mujoco && \
    wget https://roboti.us/download/mjpro150_linux.zip && \
    unzip mjpro150_linux.zip && \
    wget https://roboti.us/file/mjkey.txt

USER $NB_UID:$NB_GID
ENV PATH=${PATH}:/usr/local/nvidia/bin
