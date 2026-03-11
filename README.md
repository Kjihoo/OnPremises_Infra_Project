# OnPremises Infra Project
5인 팀 온프레미스 기차표 예약 시스템 인프라 프로젝트

---

## 전체 아키텍처

```
[외부 사용자]
      ↓ HTTPS (443)
[VM4 - Nginx 192.168.10.10]
  - HTTPS 종단 / Reverse Proxy / Rate Limiting
  - 정적 프론트엔드 서빙
      ↓ /api/ → NodePort 30080
[VM1 K8s Master 192.168.20.10]
[VM2 K8s Worker1 192.168.20.20]  ← FastAPI Pod × N (HPA 자동확장)
[VM3 K8s Worker2 192.168.20.30]
      ↓ MySQL 3306
[VM6 - MySQL 192.168.30.10]
  - 기차표 예약 DB

[VM5 - Bastion 192.168.10.20]
  - 관리자 SSH 접근 전용 (Jump Server)
```

---

## VM 구성

| VM | 역할 | CPU | RAM | 디스크 | IP |
|----|------|-----|-----|--------|----|
| VM1 | K8s Master | 2코어 | 4GB | 40GB | 192.168.20.10 |
| VM2 | K8s Worker1 | 2코어 | 4GB | 40GB | 192.168.20.20 |
| VM3 | K8s Worker2 | 2코어 | 4GB | 40GB | 192.168.20.30 |
| VM4 | Nginx | 1코어 | 2GB | 20GB | 192.168.10.10 |
| VM5 | Bastion | 1코어 | 2GB | 20GB | 192.168.10.20 |
| VM6 | MySQL | 1코어 | 2GB | 30GB | 192.168.30.10 |

---

## 파트별 담당

| 담당 | 역할 | VM | git 폴더 |
|------|------|----|----------|
| 담당1 | K8s 클러스터 인프라 | VM1,2,3 | `part1-vmware-k8s-cluster/` |
| 담당2 | 컨테이너 빌드 & 배포 | VM1,2,3 | `part2-devops-container/` |
| 담당3 | K8s 오토스케일링 & 안정성 | VM1,2,3 | `part2-devops-container/k8s/` |
| 담당4 | 웹서버 & 프록시 | VM4 | `part4-frontend-edge-security/` |
| 담당5 | DB & 보안 접근 제어 | VM5,6 | `part3-database-storage/` |

---

## 폴더 구조

```
OnPremises_Infra_Project/
├── part1-vmware-k8s-cluster/     # 담당1 - K8s 클러스터 설치 스크립트
├── part2-devops-container/       # 담당2,3 - FastAPI 앱 + K8s YAML
│   ├── app/                      # FastAPI 소스코드
│   └── k8s/                      # Deployment, Service, HPA, ConfigMap, Secret, Metrics Server
├── part3-database-storage/       # 담당5 - MySQL + Bastion 설치 스크립트
├── part4-frontend-edge-security/ # 담당4 - Nginx, 프론트엔드, SSL
├── part5-loadtest-monitoring/    # 공용 - JMeter 부하테스트
└── common-gns3-network/          # 공용 - GNS3 네트워크 설정
```

---

## 시현 시나리오

1. **담당1** : `kubectl get nodes` → VM1,2,3 Ready 상태 확인
2. **담당2** : `kubectl get pods` → FastAPI Pod Running 확인 / 롤링 업데이트
3. **담당3** : JMeter 부하 → `kubectl get hpa` → Pod 자동 증가 확인
4. **담당4** : `https://192.168.10.10` 브라우저 접속 → 기차표 예약 페이지
5. **담당5** : MySQL 재시작 후 데이터 보존 확인 / Bastion SSH 접근

---

## 기술 스택

| 분류 | 기술 |
|------|------|
| Backend | FastAPI (Python 3.11), SQLAlchemy |
| Container | Docker, Kubernetes (kubeadm) |
| Network | Flannel CNI, Nginx Reverse Proxy |
| Database | MySQL 8.0 |
| Security | Bastion Host, HTTPS (self-signed), Rate Limiting |
| Monitoring | Metrics Server, HPA, kubectl top |
