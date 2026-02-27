#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "Starting ShardingSphere Proxy Demo..."
echo "--------------------------------------"

# 检查是否安装了 mysql 客户端
if ! command -v mysql &> /dev/null
then
    echo -e "${RED}Error: mysql client could not be found. Please install it first.${NC}"
    exit 1
fi

# 启动容器
docker-compose up -d

echo "Waiting for ShardingSphere Proxy to be ready (this may take a minute)..."

# 简单的重试逻辑
MAX_RETRIES=30
COUNT=0
while ! mysql -h 127.0.0.1 -P 3307 -u root -pdemo -e "SELECT 1" &> /dev/null; do
    printf "."
    sleep 2
    COUNT=$((COUNT+1))
    if [ $COUNT -ge $MAX_RETRIES ]; then
        echo -e "\n${RED}Error: ShardingSphere Proxy failed to start in time.${NC}"
        docker-compose logs demo-proxy
        exit 1
    fi
done

echo -e "\n${GREEN}Proxy is ready! Running validation queries...${NC}"
echo "--------------------------------------"

echo "1. Version Info:"
mysql -h 127.0.0.1 -P 3307 -u root -pdemo -e "SELECT VERSION();"

echo -e "\n2. Show Databases:"
mysql -h 127.0.0.1 -P 3307 -u root -pdemo -e "SHOW DATABASES;"

echo -e "\n3. Show Tables in demo_db:"
mysql -h 127.0.0.1 -P 3307 -u root -pdemo -e "USE demo_db; SHOW TABLES;"

echo -e "\n4. Select data from users table:"
mysql -h 127.0.0.1 -P 3307 -u root -pdemo -e "USE demo_db; SELECT * FROM users;"

echo "--------------------------------------"
echo -e "${GREEN}Validation complete!${NC}"
echo "To stop the demo, run: docker-compose down"
