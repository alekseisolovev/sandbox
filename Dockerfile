FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

ENV USER_NAME=user      
ENV GROUP_NAME=group    
ENV HOME=/home/user 

ARG USER_ID=1000
ARG GROUP_ID=1000

RUN groupadd --system --gid ${GROUP_ID} ${GROUP_NAME} \
    && useradd --system --uid ${USER_ID} --gid ${GROUP_NAME} --no-log-init --home ${HOME} --create-home --shell /sbin/nologin ${USER_NAME}

WORKDIR /sandbox

RUN apt-get update && apt-get install -y --no-install-recommends \
    graphviz \
    libgraphviz-dev \
    pkg-config \
    build-essential \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

RUN chown -R ${USER_NAME}:${GROUP_NAME} /sandbox
USER ${USER_NAME}
