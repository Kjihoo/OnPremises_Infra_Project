# 담당1 - K8s 클러스터 인프라

## 담당 VM
| VM | 역할 | IP |
|----|------|----|
| VM1 | K8s Master | 192.168.20.10 |
| VM2 | K8s Worker1 | 192.168.20.20 |
| VM3 | K8s Worker2 | 192.168.20.30 |

## 할 일 순서

### 1단계 - VM1, VM2, VM3 공통 작업
```bash
bash scripts/install-k8s-common.sh
```
- swap 비활성화
- containerd 설치
- kubeadm / kubelet / kubectl 설치
- 커널 파라미터 설정

### 2단계 - Master 초기화 (VM1만)
```bash
bash scripts/install-k8s-master.sh
```
- kubeadm init
- kubeconfig 설정
- Flannel CNI 설치

### 3단계 - Worker Join (VM2, VM3)
```bash
# Master 초기화 후 출력되는 join 명령어 실행
# 예시:
kubeadm join 192.168.20.10:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>
```

### 4단계 - 완료 확인
```bash
kubectl get nodes
# 출력 예시:
# NAME   STATUS   ROLES           AGE   VERSION
# vm1    Ready    control-plane   5m    v1.28.x
# vm2    Ready    <none>          3m    v1.28.x
# vm3    Ready    <none>          3m    v1.28.x
```

## 시현 포인트
- `kubectl get nodes` → 3개 모두 **Ready** 상태
- VM2 강제 종료 → Pod 자동으로 VM3으로 재스케줄링 확인

## 폴더 구조
```
part1-vmware-k8s-cluster/
├── scripts/
│   ├── install-k8s-common.sh   # VM1,2,3 공통 설치
│   └── install-k8s-master.sh   # VM1 Master 초기화
└── README.md
```
