from pydantic import BaseModel
from typing import Optional

# 예약 생성 요청
class ReservationCreate(BaseModel):
    train_no: str
    departure: str
    destination: str
    date: str
    passenger: str
    seat_no: str

# 예약 응답
class ReservationResponse(BaseModel):
    id: int
    train_no: str
    departure: str
    destination: str
    date: str
    passenger: str
    seat_no: str
    status: str

    class Config:
        from_attributes = True
