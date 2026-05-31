#!/bin/bash

set -e

echo "============================================"
echo "🚀 AI 学术写作助手 - 启动中..."
echo "============================================"

# 等待 PostgreSQL 就绪
echo "⏳ 等待 PostgreSQL 数据库就绪..."
until python -c "
import sys, os
try:
    from sqlalchemy import create_engine
    engine = create_engine(os.environ['DATABASE_URL'])
    engine.connect()
    print('✅ PostgreSQL 已就绪')
    sys.exit(0)
except Exception as e:
    sys.exit(1)
" 2>/dev/null; do
    echo "⏳ PostgreSQL 未就绪，等待 2 秒..."
    sleep 2
done

echo "✅ PostgreSQL 连接成功"

cd /app

echo ""
echo "📍 服务地址: http://0.0.0.0:8000"
echo "📍 管理后台: http://0.0.0.0:8000/admin"
echo ""
echo "============================================"

exec python -m uvicorn main:app \
    --host 0.0.0.0 \
    --port 8000 \
    --workers 1 \
    --log-level info \
    --access-log
