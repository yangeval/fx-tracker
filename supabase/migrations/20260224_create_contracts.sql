-- 0. 기존 테이블 및 타입 초기화 (필요 시)
DROP TRIGGER IF EXISTS update_contracts_updated_at ON contracts;
DROP TABLE IF EXISTS contracts;
DROP TYPE IF EXISTS contract_status;

-- 1. Enum 타입 생성
CREATE TYPE contract_status AS ENUM ('BUY_ORDER', 'SELL_ORDER', 'COMPLETED');

-- 2. contracts 테이블 생성
CREATE TABLE IF NOT EXISTS contracts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE, -- 익명 테스트를 위해 NULL 허용으로 변경
    platform TEXT NOT NULL, -- 토스, 스위치원, 카뱅 등
    buy_price DECIMAL(15, 2) NOT NULL, -- 실제 매수 체결가
    sell_price DECIMAL(15, 2), -- 실제 매도 체결가 (종료 시 입력)
    target_price DECIMAL(15, 2) NOT NULL, -- 목표 매도 가격
    grid_gap DECIMAL(15, 2) DEFAULT 0, -- 그리드 간격 (차수별 매수가 차이)
    next_buy_price DECIMAL(15, 2), -- 다음 차수 매수 예정가
    quantity DECIMAL(15, 2) NOT NULL, -- 거래 수량
    status contract_status NOT NULL DEFAULT 'BUY_ORDER',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. RLS (Row Level Security) 설정
ALTER TABLE contracts ENABLE ROW LEVEL SECURITY;

-- 내 데이터만 조회
CREATE POLICY "Users can view their own contracts"
ON contracts FOR SELECT
USING (auth.uid() = user_id);

-- 내 데이터만 추가
CREATE POLICY "Users can insert their own contracts"
ON contracts FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- 내 데이터만 수정
CREATE POLICY "Users can update their own contracts"
ON contracts FOR UPDATE
USING (auth.uid() = user_id);

-- 내 데이터만 삭제
CREATE POLICY "Users can delete their own contracts"
ON contracts FOR DELETE
USING (auth.uid() = user_id);

-- 4. updated_at 자동 갱신 트리거 (필요 시)
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_contracts_updated_at
    BEFORE UPDATE ON contracts
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 5. 개발용 임시 정책: 익명 사용자도 테스트 가능하게 허용 (배포 시 제거 권장)
CREATE POLICY "Allow anonymous temporary access"
ON contracts FOR ALL
USING (true)
WITH CHECK (true);
