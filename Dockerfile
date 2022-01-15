#Download base image ubuntu 18.04
FROM python:3.8 
COPY --from=openjdk:8-jre-slim /usr/local/openjdk-8 /usr/local/openjdk-8

ENV HOME /app/
WORKDIR ${HOME}

ENV JAVA_HOME /usr/local/openjdk-8



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

RUN pip3 install poetry

COPY pyproject.toml poetry.lock ${HOME}
RUN poetry install
RUN mkdir ${HOME}/notebooks/

# COPY ./neo4j-connector-apache-spark-4.1.0/neo4j-connector-apache-spark_2.12-4.1.0_for_spark_3.jar ${HOME}/notebooks

WORKDIR ${HOME}

RUN poetry run jupyter notebook --generate-config 
RUN echo "c.NotebookApp.notebook_dir = '/app/notebooks'" >> /app/.jupyter/jupyter_notebook_config.py



# ENV POETRY_SPARK_HOME=/app/spark-2.4.5-bin-hadoop2.7
# ENV POETRY_PYTHONPATH=$SPARK_HOME/python;$SPARK_HOME/python/lib/py4j-0.10.7-src.zip;$PYTHONPATH
# ENV POETRY_PATH=$SPARK_HOME/bin:$SPARK_HOME/python:$PATH
