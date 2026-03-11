# 담당2 - 컨테이너 빌드 & 배포 / 담당3 - 오토스케일링 & 안정성

## 담당 VM
VM1(Master), VM2(Worker1), VM3(Worker2) - K8s 클러스터 위에서 작업

---

## 담당2 - 컨테이너 빌드 & 배포

### 할 일

#### 1. Docker 이미지 빌드 (VM1에서 실행)
```bash
cd part2-devops-container/
docker build -t train-api:latest .
```

#### 2. K8s 배포
```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secret.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

#### 3. 확인
```bash
kubectl get pods          # Running 상태 확인
kubectl get svc           # NodePort 30080 확인
curl http://192.168.20.10:30080/health  # API 응답 확인
```

#### 4. 롤링 업데이트 시현
```bash
# 이미지 버전 변경 후
kubectl set image deployment/train-api train-api=train-api:v2
kubectl rollout status deployment/train-api   # 무중단 배포 확인
```

---

## 담당3 - K8s 오토스케일링 & 안정성

### 할 일

#### 1. Metrics Server 설치 (HPA 작동에 필수)
```bash
kubectl apply -f k8s/metrics-server.yaml
# 설치 확인 (1-2분 대기)
kubectl top nodes
kubectl top pods
```

#### 2. HPA 적용
```bash
kubectl apply -f k8s/hpa.yaml
kubectl get hpa   # 확인
```

#### 3. Probe 동작 확인
```bash
kubectl describe pod <pod-name>   # liveness/readiness probe 확인
```

#### 4. HPA 시현
```bash
# 부하 발생 시 (담당5 JMeter 또는 직접)
watch kubectl get hpa   # CPU 증가 → Pod 수 자동 증가
```

---

## 폴더 구조
```
part2-devops-container/
├── app/
│   ├── main.py           # FastAPI 앱 (예약 CRUD API)
│   ├── database.py       # DB 연결 (MySQL/SQLite 전환 가능)
│   ├── models.py         # SQLAlchemy 모델
│   ├── schemas.py        # Pydantic 스키마
│   └── requirements.txt
├── k8s/
│   ├── deployment.yaml   # Pod 배포 (replicas:2, RollingUpdate)
│   ├── service.yaml      # ClusterIP + NodePort 30080
│   ├── hpa.yaml          # CPU 50% 기준, min2 max10
│   ├── configmap.yaml    # DB_HOST: 192.168.30.10
│   ├── secret.yaml       # DB 계정정보
│   └── metrics-server.yaml  # Metrics Server (HPA 필수)
├── Dockerfile
└── README.md
```

## API 목록
| Method | URL | 설명 |
|--------|-----|------|
| GET | /health | 헬스체크 |
| POST | /reservation | 예약 생성 |
| GET | /reservations | 전체 예약 조회 |
| GET | /reservation/{id} | 단건 조회 |
| DELETE | /reservation/{id} | 예약 취소 |

## 로컬 테스트 (MySQL 없이)
```bash
# Windows PowerShell
$env:DATABASE_URL="sqlite:///./test.db"; uvicorn app.main:app --reload
```
