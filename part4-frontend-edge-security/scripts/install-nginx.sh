#!/bin/bash
# =====================================================
# VM4 - Nginx 설치 및 설정 스크립트 (Ubuntu 22.04)
# =====================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== [1/4] Nginx 설치 ==="
sudo apt update && sudo apt install -y nginx openssl

echo "=== [2/4] SSL 인증서 생성 ==="
bash "$SCRIPT_DIR/gen-ssl.sh"

echo "=== [3/4] Nginx 설정 복사 ==="
sudo cp "$SCRIPT_DIR/../nginx/nginx.conf" /etc/nginx/nginx.conf

echo "=== [4/4] 프론트엔드 파일 복사 ==="
sudo mkdir -p /var/www/html
sudo cp -r "$SCRIPT_DIR/../frontend/." /var/www/html/

echo "=== Nginx 재시작 ==="
sudo nginx -t && sudo systemctl restart nginx
sudo systemctl enable nginx

echo ""
echo "=== 설치 완료 ==="
echo "HTTP  → HTTPS 자동 리다이렉트"
echo "HTTPS → 정적 프론트엔드 서빙"
echo "HTTPS /api/ → K8s 백엔드 Reverse Proxy"
