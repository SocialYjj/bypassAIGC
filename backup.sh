#!/bin/bash
# ============================================
# PostgreSQL 数据库备份脚本
# ============================================
# 使用方法:
#   chmod +x backup.sh
#   ./backup.sh
#
# 定时备份（每天凌晨2点）:
#   crontab -e
#   0 2 * * * /path/to/backup.sh
# ============================================

# 配置
BACKUP_DIR="./backups"
CONTAINER_NAME="ai-writing-postgres"
DB_NAME="${DB_NAME:-ai_polish}"
DB_USER="${DB_USER:-ai_polish}"
RETENTION_DAYS=7

# 创建备份目录
mkdir -p "$BACKUP_DIR"

# 生成备份文件名
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/backup_${TIMESTAMP}.sql.gz"

# 执行备份
echo "开始备份数据库: $DB_NAME"
docker exec "$CONTAINER_NAME" pg_dump -U "$DB_USER" -d "$DB_NAME" | gzip > "$BACKUP_FILE"

# 检查备份是否成功
if [ $? -eq 0 ]; then
    echo "✅ 备份成功: $BACKUP_FILE"
    echo "   文件大小: $(du -h "$BACKUP_FILE" | cut -f1)"
else
    echo "❌ 备份失败"
    exit 1
fi

# 删除旧备份
echo "清理 ${RETENTION_DAYS} 天前的备份..."
find "$BACKUP_DIR" -name "backup_*.sql.gz" -mtime +$RETENTION_DAYS -delete

echo "备份完成"
