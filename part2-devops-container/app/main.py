from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
import models
import schemas
from database import engine, get_db

# 앱 시작 시 테이블 자동 생성
models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="기차표 예약 시스템", version="1.0.0")


# ── 헬스체크 ──────────────────────────────────────────────
# K8s liveness / readiness probe 에서 이 엔드포인트를 호출함
@app.get("/health")
def health_check():
    return {"status": "ok", "version": "1.0.0"}


# ── 예약 생성 ─────────────────────────────────────────────
@app.post("/reservation", response_model=schemas.ReservationResponse, status_code=201)
def create_reservation(req: schemas.ReservationCreate, db: Session = Depends(get_db)):
    reservation = models.Reservation(**req.model_dump())
    db.add(reservation)
    db.commit()
    db.refresh(reservation)
    return reservation


# ── 예약 단건 조회 ────────────────────────────────────────
@app.get("/reservation/{reservation_id}", response_model=schemas.ReservationResponse)
def get_reservation(reservation_id: int, db: Session = Depends(get_db)):
    reservation = db.query(models.Reservation).filter(
        models.Reservation.id == reservation_id
    ).first()
    if not reservation:
        raise HTTPException(status_code=404, detail="예약을 찾을 수 없습니다")
    return reservation


# ── 전체 예약 목록 ────────────────────────────────────────
@app.get("/reservations", response_model=List[schemas.ReservationResponse])
def list_reservations(db: Session = Depends(get_db)):
    return db.query(models.Reservation).all()


# ── 예약 취소 ─────────────────────────────────────────────
@app.delete("/reservation/{reservation_id}")
def cancel_reservation(reservation_id: int, db: Session = Depends(get_db)):
    reservation = db.query(models.Reservation).filter(
        models.Reservation.id == reservation_id
    ).first()
    if not reservation:
        raise HTTPException(status_code=404, detail="예약을 찾을 수 없습니다")
    reservation.status = "cancelled"
    db.commit()
    return {"message": "예약이 취소되었습니다", "id": reservation_id}
