#Download base image ubuntu 18.04
FROM python:3.8 
COPY --from=openjdk:8-jre-slim /usr/local/openjdk-8 /usr/local/openjdk-8

ENV JAVA_HOME /usr/local/openjdk-8


ENV NB_USER drobinson
ENV NB_UID 1000
ENV HOME /app/
WORKDIR ${HOME}

ENV PYSPARK_PYTHON=python3
ENV PYSPARK_DRIVER_PYTHON=python3

RUN apt-get update && apt-get install -y \
    tar \
    wget \
    bash \
    rsync \
    gcc \
    libfreetype6-dev \
    libhdf5-serial-dev \
    libpng-dev \
    libzmq3-dev \
    python3 \
    python3-dev \
    python3-pip \
    unzip \
    pkg-config \
    software-properties-common \
    graphviz \
    git \
    vim

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}

RUN pip3 install poetry

COPY pyproject.toml poetry.lock ${HOME}
RUN poetry install
RUN mkdir ${HOME}/notebooks/

USER root
RUN chown -R ${NB_UID} ${HOME}
USER ${NB_USER}

WORKDIR ${HOME}

RUN poetry run jupyter notebook --generate-config 
RUN echo "c.NotebookApp.notebook_dir = '/app/notebooks'" >> /app/.jupyter/jupyter_notebook_config.py