#!/bin/bash
# =====================================================
# K8s 공통 설치 스크립트 - VM1, VM2, VM3 모두 실행
# Ubuntu 22.04 기준
# =====================================================

set -e

echo "============================================="
echo " K8s 공통 설치 시작 (VM1, VM2, VM3 모두 실행)"
echo "============================================="

echo ""
echo "=== [1/7] swap 비활성화 ==="
sudo swapoff -a
# 재부팅 후에도 유지
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
echo "swap 비활성화 완료"

echo ""
echo "=== [2/7] 커널 모듈 로드 ==="
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter

echo ""
echo "=== [3/7] 커널 파라미터 설정 ==="
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system

echo ""
echo "=== [4/7] containerd 설치 ==="
sudo apt update
sudo apt install -y ca-certificates curl gnupg

# Docker 공식 GPG 키
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Docker 저장소 추가
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y containerd.io

# containerd 기본 설정 생성
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
# SystemdCgroup 활성화 (kubeadm 필수)
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

sudo systemctl restart containerd
sudo systemctl enable containerd
echo "containerd 설치 완료"

echo ""
echo "=== [5/7] kubeadm, kubelet, kubectl 설치 (v1.28) ==="
sudo apt install -y apt-transport-https

# K8s 공식 저장소
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | \
  sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | \
  sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt update
sudo apt install -y kubelet kubeadm kubectl
# 버전 고정 (자동 업그레이드 방지)
sudo apt-mark hold kubelet kubeadm kubectl

sudo systemctl enable kubelet
echo "kubeadm, kubelet, kubectl 설치 완료"

echo ""
echo "=== [6/7] hostname 확인 ==="
echo "현재 hostname: $(hostname)"
echo "[!] 각 VM의 hostname이 달라야 함"
echo "    VM1: sudo hostnamectl set-hostname k8s-master"
echo "    VM2: sudo hostnamectl set-hostname k8s-worker1"
echo "    VM3: sudo hostnamectl set-hostname k8s-worker2"

echo ""
echo "=== [7/7] /etc/hosts 설정 ==="
# 이미 없을 경우에만 추가
grep -qxF '192.168.20.10 k8s-master' /etc/hosts || \
  echo '192.168.20.10 k8s-master' | sudo tee -a /etc/hosts
grep -qxF '192.168.20.20 k8s-worker1' /etc/hosts || \
  echo '192.168.20.20 k8s-worker1' | sudo tee -a /etc/hosts
grep -qxF '192.168.20.30 k8s-worker2' /etc/hosts || \
  echo '192.168.20.30 k8s-worker2' | sudo tee -a /etc/hosts

echo ""
echo "============================================="
echo " 공통 설치 완료!"
echo " 다음 단계:"
echo "   VM1 → bash install-k8s-master.sh"
echo "   VM2, VM3 → Master 초기화 후 kubeadm join 실행"
echo "============================================="
