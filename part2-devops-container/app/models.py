from sqlalchemy import Column, Integer, String, DateTime
from sqlalchemy.sql import func
from database import Base

class Reservation(Base):
    __tablename__ = "reservations"

    id           = Column(Integer, primary_key=True, autoincrement=True)
    train_no     = Column(String(20), nullable=False)   # 열차 번호 (예: KTX-101)
    departure    = Column(String(50), nullable=False)   # 출발역
    destination  = Column(String(50), nullable=False)   # 도착역
    date         = Column(String(20), nullable=False)   # 출발 날짜 (YYYY-MM-DD)
    passenger    = Column(String(50), nullable=False)   # 승객 이름
    seat_no      = Column(String(10), nullable=False)   # 좌석 번호
    status       = Column(String(20), default="confirmed")  # confirmed / cancelled
    created_at   = Column(DateTime, server_default=func.now())
