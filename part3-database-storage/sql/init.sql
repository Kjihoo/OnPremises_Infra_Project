-- =====================================================
-- 기차표 예약 시스템 - MySQL 초기화 스크립트
-- VM6 (DB 전용 VM) 에서 실행
-- =====================================================

-- 1. 데이터베이스 생성
CREATE DATABASE IF NOT EXISTS traindb
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

-- 2. 백엔드 전용 계정 생성
--    '%' = 모든 IP에서 접근 허용 (방화벽 ACL로 IP 제한은 파트1에서 처리)
CREATE USER IF NOT EXISTS 'trainuser'@'%' IDENTIFIED BY 'trainpass123';
GRANT ALL PRIVILEGES ON traindb.* TO 'trainuser'@'%';
FLUSH PRIVILEGES;

-- 3. 테이블 생성
USE traindb;

CREATE TABLE IF NOT EXISTS reservations (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    train_no    VARCHAR(20)  NOT NULL,              -- 열차번호 (예: KTX-101)
    departure   VARCHAR(50)  NOT NULL,              -- 출발역
    destination VARCHAR(50)  NOT NULL,              -- 도착역
    date        VARCHAR(20)  NOT NULL,              -- 출발날짜 (YYYY-MM-DD)
    passenger   VARCHAR(50)  NOT NULL,              -- 승객 이름
    seat_no     VARCHAR(10)  NOT NULL,              -- 좌석번호 (예: 3A)
    status      VARCHAR(20)  DEFAULT 'confirmed',   -- confirmed / cancelled
    created_at  DATETIME     DEFAULT NOW()
);

-- 4. 테스트 데이터 (시연용)
INSERT INTO reservations (train_no, departure, destination, date, passenger, seat_no)
VALUES
  ('KTX-101', '서울', '부산', '2026-03-20', '홍길동', '3A'),
  ('KTX-202', '서울', '대구', '2026-03-21', '김철수', '5B'),
  ('SRT-303', '수서', '광주', '2026-03-22', '이영희', '7C');

SELECT '초기화 완료' AS result;
