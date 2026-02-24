# Task: FX-Tracker Implementation

## Context
사용자 중심의 경량 환테크(FX Grid Trading) 관리 도구 구축. 그리드 트레이딩 전략에 기반한 매수 타점 자동 산출 및 실시간 수익률 트래킹 시스템 구현.

## Todo List

### Phase 1: Infrastructure & Data Model [x]
- [x] **Agent Infrastructure**: `.agent` 서브모듈 독립 및 `.agent_memory` 분리 (완료)
- [x] **Database Schema**: `contracts` 테이블 생성 및 Grid Trading 필드(`grid_gap`, `next_buy_price`) 반영 (완료)
- [x] **RLS Policy**: 보안 정책 수립 및 개발용 익명 접근 허용 정책 추가 (완료)

### Phase 2: Frontend Foundation & Core Features [x]
- [x] **SvelteKit Setup**: Supabase 클라이언트 연동 및 모바일 레이아웃 구성 (완료)
- [x] **Dashboard Module**: 그리드 타점 기반 실시간 수익률(실현/기대) 통계 헤더 구현 (완료)
- [x] **Transaction Module**: 빠른 거래 추가 및 '매수 주문 -> 매도 주문 -> 종료' 상태 전환 워크플로우 구현 (완료)

### Phase 3: Authentication & Security [/]
- [ ] **Login/Signup UI**: Supabase Auth 연동 회원가입 및 로그인 페이지 구축
- [ ] **Auth Guard**: 인증 여부에 따른 페이지 접근 제한 및 `user_id` 기반 데이터 격리 강화
- [ ] **RLS Cleanup**: 개발용 익명 정책 제거 및 엄격한 본인 데이터 접근 정책 적용

### Phase 4: Polish & Refinement [ ]
- [ ] **History Module**: '종료'된 계약들에 대한 전수 내역 그리드 및 필터링 기능
- [ ] **Mobile Optimization**: 데이터가 많아질 경우를 대비한 가상 리스트 도입 및 UI 디테일 개선
- [ ] **Theme Support**: 사용자 눈의 피로도 감소를 위한 다크 모드 지원

## Verification Strategy
- **Functional**: '매도 완료' 시 실제 체결가 입력에 따른 실현 수익 계산 정확도 검증
- **Realtime**: 여러 기기 동시 접속 시 Supabase Realtime을 통한 데이터 동기화 지연 시간 확인
- **Security**: 로그인하지 않은 상태에서 API를 통한 데이터 접근 차단 여부 확인
