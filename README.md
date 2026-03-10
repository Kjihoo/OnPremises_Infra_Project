# OnPremises Infra Project

5인 팀 온프레미스 기반 하이브리드 인프라 프로젝트

## 아키텍처 개요

```
[외부 사용자]
      ↓
[GNS3 가상 네트워크] - VLAN 망분리 / 방화벽 ACL
      ↓
[DMZ 존] - Nginx (Reverse Proxy + HTTPS + 정적 프론트엔드)
      ↓
[Private 존] - VMware K8s 클러스터
  └── FastAPI 기차표 예약 Pod × N (HPA 자동 확장)
      ↓
[DB 존] - MySQL Pod + PVC (영속 스토리지)
```

## 팀 역할 분담

| 파트 | 역할 | 담당 기술 |
|------|------|----------|
| Part 1 | 프론트엔드 & 엣지 보안 | Nginx, HTTPS, Reverse Proxy, Bastion |
| Part 2 | VMware & K8s 플랫폼 | VMware, kubeadm, CNI, Ingress |
| Part 3 | DevOps & 컨테이너 배포 | Docker, K8s YAML, HPA, Rolling Update |
| Part 4 | DB & 스토리지 | MySQL, PV, PVC, 데이터 영속성 |
| Part 5 | GNS3 네트워크 & 보안 | GNS3, VLAN, 방화벽 ACL |

## 폴더 구조

```
OnPremises_Infra_Project/
├── part1-frontend-edge/      # Nginx, 프론트엔드, SSL
├── part2-vmware-k8s/         # VM 구성, K8s 클러스터 설정
├── part3-devops/             # 백엔드 코드, Dockerfile, K8s YAML
├── part4-database/           # MySQL, PV/PVC YAML
└── part5-network/            # GNS3 토폴로지, VLAN, 방화벽
```

## 시현 시나리오

1. **파트 1:** HTTPS 암호화 통신 / Bastion SSH 터널링 보안
2. **파트 2:** Worker 노드 다운 → K8s 자동 파드 재스케줄링 (HA)
3. **파트 3:** JMeter 부하 → HPA 스케일아웃 / 롤링 업데이트
4. **파트 4:** DB Pod 삭제 → 재생성 후 데이터 보존 (PVC)
5. **파트 5:** 외부 Ping 차단 / DB 3306 포트 마이크로 세그멘테이션
