# 담당5 - DB & 보안 접근 제어

## 담당 VM
| VM | 역할 | IP |
|----|------|----|
| VM5 | Bastion Host | 192.168.10.20 |
| VM6 | MySQL DB | 192.168.30.10 |

---

## VM6 - MySQL 설치

### 설치 실행
```bash
bash scripts/install-mysql.sh
```
- MySQL 8.0 설치
- traindb 생성
- trainuser 계정 생성 (비밀번호: trainpass123)
- reservations 테이블 생성
- 테스트 데이터 삽입

### 수동 확인
```bash
mysql -u trainuser -ptrainpass123 traindb
SELECT * FROM reservations;
```

### 데이터 영속성 시현
```bash
bash scripts/demo-persistence.sh
```
- 예약 데이터 Insert → MySQL 재시작 → 데이터 보존 확인

---

## VM5 - Bastion Host 설정

### 설치 실행
```bash
bash scripts/install-bastion.sh
```
- SSH 포트 변경 (22 → 2222)
- PasswordAuthentication 비활성화 (키 기반만 허용)
- 내부 VM으로의 SSH 포워딩 설정

### Bastion 통해 내부 VM 접근 방법
```bash
# 외부에서 Bastion 통해 VM1(Master) 접근
ssh -J user@192.168.10.20:2222 user@192.168.20.10

# 또는 SSH 터널링
ssh -L 8022:192.168.20.10:22 user@192.168.10.20 -p 2222
ssh -p 8022 user@localhost
```

---

## 폴더 구조
```
part3-database-storage/
├── sql/
│   └── init.sql                 # DB/계정/테이블 초기화 SQL
├── scripts/
│   ├── install-mysql.sh         # VM6 MySQL 설치
│   ├── install-bastion.sh       # VM5 Bastion 설정
│   └── demo-persistence.sh      # 데이터 영속성 시현
└── README.md
```

## 시현 포인트
1. **DB 영속성**: `INSERT` → `systemctl restart mysql` → `SELECT` → 데이터 유지 확인
2. **Bastion 보안**: 외부에서 VM1~6 직접 SSH 불가 → Bastion 통해서만 가능


## 작업 내용
- VM6에 MySQL 설치 완료
- traindb 생성 완료
- trainuser 계정 및 권한 설정 완료
- reservations 테이블 생성 및 테스트 데이터 삽입 완료
- MySQL 재시작 후 데이터 유지 확인 완료
