FROM python:3.11-slim AS builder

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    POETRY_VIRTUALENVS_CREATE=false

WORKDIR /sandbox

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libgraphviz-dev \
    && pip install --upgrade pip \
    && pip install poetry \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY pyproject.toml poetry.lock* ./
RUN poetry install --no-root

RUN jupyter server extension enable jupyterlab_code_formatter

FROM python:3.11-slim AS dev

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /sandbox

RUN apt-get update && apt-get install -y --no-install-recommends \
    graphviz \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /usr/local/share/jupyter /usr/local/share/jupyter
COPY --from=builder /usr/local/etc/jupyter /usr/local/etc/jupyter

ENV USER_NAME=user
ENV GROUP_NAME=group
ENV HOME=/home/user
ARG USER_ID=1000
ARG GROUP_ID=1000

RUN groupadd --system --gid ${GROUP_ID} ${GROUP_NAME} \
    && useradd --system --uid ${USER_ID} --gid ${GROUP_NAME} \
        --no-log-init --home ${HOME} --create-home --shell /bin/bash ${USER_NAME} \
    && mkdir -p /sandbox \
    && chown -R ${USER_NAME}:${GROUP_NAME} /sandbox /usr/local/etc/jupyter

COPY . .

USER ${USER_NAME}
