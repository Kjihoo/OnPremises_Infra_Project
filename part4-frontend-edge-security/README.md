# 담당4 - 웹서버 & 프록시

## 담당 VM
| VM | 역할 | IP |
|----|------|----|
| VM4 | Nginx | 192.168.10.10 |

---

## 할 일 순서

### 1. SSL 인증서 생성
```bash
bash scripts/gen-ssl.sh
# /etc/nginx/ssl/server.crt, server.key 생성됨
```

### 2. Nginx 설치 & 배포
```bash
bash scripts/install-nginx.sh
```
- Nginx 설치
- nginx.conf 적용 (HTTPS, Rate Limiting, Reverse Proxy)
- 프론트엔드 파일 `/var/www/html/` 배포

### 3. 확인
```bash
# 브라우저에서 접속
https://192.168.10.10

# HTTP → HTTPS 리다이렉트 확인
curl -I http://192.168.10.10

# API 프록시 확인 (K8s NodePort 30080으로 전달)
curl -k https://192.168.10.10/api/health
```

### 4. Rate Limiting 시현
```bash
# 빠르게 반복 요청 시 429 응답 확인
for i in {1..20}; do curl -sk -o /dev/null -w "%{http_code}\n" https://192.168.10.10/api/health; done
```

---

## 폴더 구조
```
part4-frontend-edge-security/
├── nginx/
│   └── nginx.conf           # HTTPS + Rate Limiting + Reverse Proxy
├── frontend/
│   ├── index.html           # 기차표 예약 웹 페이지
│   ├── style.css            # 스타일시트
│   └── app.js               # API 연동 (예약 생성/조회/취소)
├── scripts/
│   ├── gen-ssl.sh           # 자체서명 SSL 인증서 생성
│   └── install-nginx.sh     # Nginx 설치 + 배포 자동화
└── README.md
```

## 시현 포인트
1. **HTTPS**: `https://192.168.10.10` 접속 → 기차표 예약 UI
2. **Rate Limiting**: 초당 10req 초과 시 429 응답
3. **Reverse Proxy**: 프론트엔드에서 예약 생성 → K8s FastAPI 응답

## K8s NodePort 주소 확인
```bash
# K8s 담당자(담당2)에게 NodePort 확인 후 nginx.conf 수정 필요
# 현재 설정: http://192.168.20.10:30080/
```
