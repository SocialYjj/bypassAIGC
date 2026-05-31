# 第一阶段：构建前端
FROM node:20-alpine AS frontend-builder

WORKDIR /app/frontend

COPY package/frontend/package.json package/frontend/package-lock.json ./
RUN npm ci --production=false
COPY package/frontend/ ./
RUN npm run build && rm -rf node_modules

# ============================================
# 第二阶段：Python应用
# ============================================
FROM python:3.11-alpine

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

WORKDIR /app

COPY package/backend/requirements.txt ./backend/requirements.txt
RUN apk add --no-cache --virtual .build-deps \
    gcc musl-dev libffi-dev \
    && pip install --no-cache-dir -r backend/requirements.txt \
    && apk del .build-deps \
    && apk add --no-cache curl

COPY package/backend/ ./backend/
COPY package/main.py ./
COPY --from=frontend-builder /app/frontend/dist ./static
RUN mkdir -p /app/data

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

CMD ["sh", "-c", "\
    echo '等待数据库就绪...' && \
    python -c 'import time; time.sleep(3)' && \
    echo '启动服务...' && \
    python -m uvicorn main:app --host 0.0.0.0 --port 8000 --workers 1 --log-level info \
"]
