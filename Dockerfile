# ----- 阶段1：builder -----
FROM python:3.10-slim-bookworm AS builder
WORKDIR /build
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# ----- 阶段2：runtime -----
FROM python:3.10-slim-bookworm
ARG DOCKER_GID=999
RUN groupadd -g ${DOCKER_GID} docker && \
    useradd --create-home --shell /bin/bash --uid 1001 xplan_user && \
    usermod -aG docker xplan_user
WORKDIR /app
COPY --from=builder /root/.local /home/xplan_user/.local
ENV PATH=/home/xplan_user/.local/bin:$PATH
COPY --chown=xplan_user:xplan_user . /app
USER xplan_user
EXPOSE 5000 2222 8088
CMD ["python", "backend/app.py"]
