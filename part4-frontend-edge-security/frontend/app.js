// =====================================================
// 기차표 예약 시스템 - 프론트엔드 JS
// Nginx가 /api/ → K8s 백엔드로 Reverse Proxy
// =====================================================

const API = '/api';  // Nginx가 K8s 백엔드로 프록시

// ── 예약 목록 불러오기 ─────────────────────────────────
async function loadReservations() {
  try {
    const res = await fetch(`${API}/reservations`);
    const data = await res.json();
    renderTable(data);
  } catch (e) {
    document.getElementById('reservationList').innerHTML =
      '<tr><td colspan="9" style="color:red">서버 연결 실패</td></tr>';
  }
}

function renderTable(list) {
  const tbody = document.getElementById('reservationList');
  if (list.length === 0) {
    tbody.innerHTML = '<tr><td colspan="9" style="text-align:center">예약 없음</td></tr>';
    return;
  }
  tbody.innerHTML = list.map(r => `
    <tr>
      <td>${r.id}</td>
      <td>${r.train_no}</td>
      <td>${r.departure}</td>
      <td>${r.destination}</td>
      <td>${r.date}</td>
      <td>${r.passenger}</td>
      <td>${r.seat_no}</td>
      <td class="status-${r.status}">${r.status === 'confirmed' ? '확정' : '취소'}</td>
      <td>
        ${r.status === 'confirmed'
          ? `<button class="cancel-btn" onclick="cancelReservation(${r.id})">취소</button>`
          : '-'}
      </td>
    </tr>
  `).join('');
}

// ── 예약 생성 ──────────────────────────────────────────
document.getElementById('reservationForm').addEventListener('submit', async (e) => {
  e.preventDefault();
  const msg = document.getElementById('formMessage');
  msg.className = 'message';

  const body = {
    train_no:    document.getElementById('train_no').value,
    departure:   document.getElementById('departure').value,
    destination: document.getElementById('destination').value,
    date:        document.getElementById('date').value,
    passenger:   document.getElementById('passenger').value,
    seat_no:     document.getElementById('seat_no').value,
  };

  try {
    const res = await fetch(`${API}/reservation`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body),
    });
    if (res.ok) {
      msg.textContent = '예약이 완료되었습니다!';
      msg.className = 'message success';
      e.target.reset();
      loadReservations();
    } else {
      msg.textContent = '예약 실패: 서버 오류';
      msg.className = 'message error';
    }
  } catch {
    msg.textContent = '서버 연결 실패';
    msg.className = 'message error';
  }
});

// ── 예약 취소 ──────────────────────────────────────────
async function cancelReservation(id) {
  if (!confirm(`예약 #${id}를 취소하시겠습니까?`)) return;
  try {
    await fetch(`${API}/reservation/${id}`, { method: 'DELETE' });
    loadReservations();
  } catch {
    alert('취소 실패');
  }
}

// ── 헬스체크 ───────────────────────────────────────────
async function checkHealth() {
  const el = document.getElementById('healthStatus');
  try {
    const res = await fetch(`${API}/health`);
    const data = await res.json();
    el.textContent = `✅ 서버 정상 (${data.version})`;
    el.style.background = '#e6f4ea';
  } catch {
    el.textContent = '❌ 서버 연결 불가';
    el.style.background = '#fce8e6';
  }
}

// ── 초기 로드 ──────────────────────────────────────────
document.getElementById('refreshBtn').addEventListener('click', loadReservations);

checkHealth();
loadReservations();
setInterval(checkHealth, 30000);  // 30초마다 헬스체크
