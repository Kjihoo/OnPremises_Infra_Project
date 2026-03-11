#!/bin/bash
# =====================================================
# K8s Master 초기화 스크립트 - VM1만 실행
# IP: 192.168.20.10
# =====================================================
# 실행 전 반드시 install-k8s-common.sh 먼저 실행!
# =====================================================

set -e

MASTER_IP="192.168.20.10"
POD_CIDR="10.244.0.0/16"   # Flannel 기본값

echo "============================================="
echo " K8s Master 초기화 시작 (VM1만 실행)"
echo " Master IP: $MASTER_IP"
echo "============================================="

echo ""
echo "=== [1/4] hostname 설정 ==="
sudo hostnamectl set-hostname k8s-master
echo "k8s-master"

echo ""
echo "=== [2/4] kubeadm init ==="
sudo kubeadm init \
  --apiserver-advertise-address=$MASTER_IP \
  --pod-network-cidr=$POD_CIDR \
  --node-name=k8s-master

echo ""
echo "=== [3/4] kubeconfig 설정 ==="
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo ""
echo "=== [4/4] Flannel CNI 설치 ==="
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

echo ""
echo "============================================="
echo " Master 초기화 완료!"
echo ""
echo " 노드 상태 확인:"
echo "   kubectl get nodes"
echo ""
echo " ★ 아래 join 명령어를 Worker VM2, VM3에서 실행 ★"
echo "============================================="
echo ""

# Worker join 명령어 출력
kubeadm token create --print-join-command
echo ""
echo "위 명령어를 복사해서 VM2, VM3에서 실행하세요."
echo ""
echo " 설치 완료 후 확인:"
echo "   kubectl get nodes     # 3개 Ready 확인"
echo "   kubectl get pods -A   # kube-system Pod 상태 확인"
