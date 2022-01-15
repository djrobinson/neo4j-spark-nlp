#Download base image ubuntu 18.04
FROM python:3.8 
COPY --from=openjdk:8-jre-slim /usr/local/openjdk-8 /usr/local/openjdk-8

ENV NB_USER drobinson
ENV NB_UID 1000
ENV HOME /app/
WORKDIR ${HOME}

RUN echo "$LOG_TAG Download Spark binary" && \
    wget -O /tmp/spark-2.4.5-bin-hadoop2.7.tgz https://archive.apache.org/dist/spark/spark-2.4.5/spark-2.4.5-bin-hadoop2.7.tgz && \
    tar -zxvf /tmp/spark-2.4.5-bin-hadoop2.7.tgz && \
    rm -rf /tmp/spark-2.4.5-bin-hadoop2.7.tgz

RUN pip install spark-nlp==3.4.0



ENV JAVA_HOME /usr/local/openjdk-8



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



ENV POETRY_SPARK_HOME=/app/spark-2.4.5-bin-hadoop2.7
ENV POETRY_PYTHONPATH=$SPARK_HOME/python;$SPARK_HOME/python/lib/py4j-0.10.7-src.zip;$PYTHONPATH
ENV POETRY_PATH=$SPARK_HOME/bin:$SPARK_HOME/python:$PATH