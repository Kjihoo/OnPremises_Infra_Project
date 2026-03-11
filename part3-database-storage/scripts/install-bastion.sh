#!/bin/bash
# =====================================================
# VM5 - Bastion Host 설정 스크립트 (Ubuntu 22.04)
# IP: 192.168.10.20
# =====================================================

set -e

echo "=== [1/5] 패키지 업데이트 ==="
sudo apt update && sudo apt upgrade -y

echo "=== [2/5] SSH 서버 설치 확인 ==="
sudo apt install -y openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh

echo "=== [3/5] SSH 보안 설정 ==="
# SSH 포트 2222로 변경, 루트 로그인 차단, 비밀번호 인증 비활성화
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

sudo tee /etc/ssh/sshd_config > /dev/null <<'EOF'
# ── 기본 설정 ──────────────────────────────────────
Port 2222
AddressFamily inet
ListenAddress 0.0.0.0

# ── 인증 설정 (키 기반만 허용) ──────────────────────
PermitRootLogin no
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
PasswordAuthentication no
PermitEmptyPasswords no
ChallengeResponseAuthentication no

# ── SSH 터널링 허용 (Jump Server 역할) ───────────────
AllowTcpForwarding yes
GatewayPorts no
X11Forwarding no

# ── 타임아웃 설정 ───────────────────────────────────
ClientAliveInterval 300
ClientAliveCountMax 2
LoginGraceTime 30

# ── 로그 ───────────────────────────────────────────
LogLevel VERBOSE
EOF

echo "=== [4/5] SSH 키 생성 (없을 경우) ==="
if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
    echo "[!] 공개키를 내부 VM들에 복사 필요:"
    echo "    ssh-copy-id -p 22 user@192.168.20.10   # VM1 Master"
    echo "    ssh-copy-id -p 22 user@192.168.20.20   # VM2 Worker1"
    echo "    ssh-copy-id -p 22 user@192.168.20.30   # VM3 Worker2"
    echo "    ssh-copy-id -p 22 user@192.168.30.10   # VM6 MySQL"
fi

echo "=== [5/5] UFW 방화벽 설정 ==="
sudo apt install -y ufw
# 기본 정책: 모두 차단
sudo ufw default deny incoming
sudo ufw default allow outgoing
# Bastion SSH 포트만 허용
sudo ufw allow 2222/tcp comment 'Bastion SSH'
sudo ufw --force enable

echo "=== SSH 재시작 ==="
sudo systemctl restart ssh

echo ""
echo "=== Bastion 설정 완료 ==="
echo "외부 접속 방법: ssh -p 2222 user@192.168.10.20"
echo ""
echo "Jump Server로 내부 VM 접근 방법:"
echo "  ssh -J user@192.168.10.20:2222 user@192.168.20.10  # VM1 Master"
echo "  ssh -J user@192.168.10.20:2222 user@192.168.20.20  # VM2 Worker1"
echo "  ssh -J user@192.168.10.20:2222 user@192.168.20.30  # VM3 Worker2"
echo "  ssh -J user@192.168.10.20:2222 user@192.168.30.10  # VM6 MySQL"
echo ""
echo "[!] 주의: 이 설정 후 비밀번호 로그인 불가 → SSH 키 먼저 등록 필수"
