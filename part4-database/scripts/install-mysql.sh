#!/bin/bash
# =====================================================
# VM6 - MySQL 설치 및 초기화 스크립트 (Ubuntu 22.04)
# =====================================================

set -e

echo "=== [1/4] 패키지 업데이트 ==="
sudo apt update

echo "=== [2/4] MySQL 설치 ==="
sudo apt install -y mysql-server

echo "=== [3/4] MySQL 서비스 시작 및 부팅 자동 시작 등록 ==="
sudo systemctl start mysql
sudo systemctl enable mysql

echo "=== [4/4] 초기 DB/계정/테이블 생성 ==="
# 스크립트 위치 기준으로 sql 파일 실행
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
sudo mysql < "$SCRIPT_DIR/../sql/init.sql"

echo ""
echo "=== 설치 완료 ==="
echo "DB:   traindb"
echo "User: trainuser / trainpass123"
echo "Port: 3306"
echo ""
echo "[!] 파트3 configmap.yaml 의 DB_HOST 를 이 VM 의 IP 로 변경 필요"
ip addr show | grep "inet " | grep -v "127.0.0.1"
