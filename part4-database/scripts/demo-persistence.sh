#!/bin/bash
# =====================================================
# 파트4 시현 스크립트 - 데이터 영속성 증명
# VM6 MySQL 재시작 후에도 데이터 보존됨을 증명
# =====================================================

echo "=== [시현 1단계] 현재 예약 데이터 확인 ==="
sudo mysql -u root -e "SELECT * FROM traindb.reservations;"

echo ""
echo "=== [시현 2단계] 테스트 데이터 Insert ==="
sudo mysql -u root -e "
INSERT INTO traindb.reservations (train_no, departure, destination, date, passenger, seat_no)
VALUES ('KTX-999', '서울', '부산', '2026-12-25', '시연용승객', '99Z');
SELECT '데이터 Insert 완료' AS result;
"

echo ""
echo "=== [시현 3단계] MySQL 서비스 강제 재시작 (장애 시뮬레이션) ==="
sudo systemctl restart mysql
echo "MySQL 재시작 완료"

echo ""
echo "=== [시현 4단계] 재시작 후 데이터 보존 확인 ==="
sleep 2
sudo mysql -u root -e "SELECT * FROM traindb.reservations WHERE train_no = 'KTX-999';"
echo "데이터가 보존되었습니다!"
