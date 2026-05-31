# ============================================
# AI 学术写作助手 - Docker镜像
# ============================================

# 第一阶段：构建前端
FROM node:20-slim AS frontend-builder

WORKDIR /app/frontend

# 复制前端依赖文件
COPY package/frontend/package.json package/frontend/package-lock.json ./

# 安装依赖
RUN npm ci

# 复制前端源码
COPY package/frontend/ ./

# 构建前端
RUN npm run build

# ============================================
# 第二阶段：Python应用
# ============================================
FROM python:3.11-slim

# 设置环境变量
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# 安装系统依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 创建应用目录
WORKDIR /app

# 复制后端依赖文件
COPY package/backend/requirements.txt ./backend/requirements.txt
COPY package/requirements.txt ./requirements.txt

# 安装Python依赖
RUN pip install --no-cache-dir -r backend/requirements.txt

# 复制后端代码
COPY package/backend/ ./backend/
COPY package/main.py ./

# 复制前端构建产物
COPY --from=frontend-builder /app/frontend/dist ./static

# 创建数据目录
RUN mkdir -p /app/data

# 创建启动脚本
COPY docker-entrypoint.sh /app/
RUN chmod +x /app/docker-entrypoint.sh

# 暴露端口
EXPOSE 8000

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# 启动应用
ENTRYPOINT ["/app/docker-entrypoint.sh"]
