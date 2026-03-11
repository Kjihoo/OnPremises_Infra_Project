#!/bin/bash
# =====================================================
# 자체 서명 SSL 인증서 생성 스크립트 (VM4에서 실행)
# =====================================================

sudo mkdir -p /etc/nginx/ssl

sudo openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/server.key \
  -out    /etc/nginx/ssl/server.crt \
  -subj   "/C=KR/ST=Seoul/L=Seoul/O=TrainSystem/CN=train.local"

echo "SSL 인증서 생성 완료"
echo "  CRT: /etc/nginx/ssl/server.crt"
echo "  KEY: /etc/nginx/ssl/server.key"
