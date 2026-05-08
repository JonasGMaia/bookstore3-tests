FROM python:3.14-slim AS python-base

# Variáveis de ambiente
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=off \
    POETRY_VERSION=2.3.2 \
    POETRY_HOME="/opt/poetry" \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_NO_INTERACTION=1 \
    PYSETUP_PATH="/opt/pysetup" \
    VENV_PATH="/opt/pysetup/.venv"

# Ajuste do PATH para encontrar o Poetry e o Venv
ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"

# Dependências do sistema (incluindo as necessárias para psycopg2)
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        curl \
        build-essential \
        libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Instala o Poetry respeitando o POETRY_HOME
RUN curl -sSL https://install.python-poetry.org | python3 -

# RUN apt-get update \
#     && apt-get -y install libpq-dev gcc \
#     && pip install psycopg2 

# Configura diretório de trabalho para dependências
WORKDIR $PYSETUP_PATH
COPY poetry.lock pyproject.toml ./

# Instala apenas dependências de runtime (main)
RUN poetry install --only main --no-root

# Configura diretório da aplicação
WORKDIR /app
COPY . /app/

EXPOSE 8000

CMD ["gunicorn", "core.wsgi:application", "--bind", "0.0.0.0:8000"]