# Technology Stack: FX-Tracker

## 1. Frontend
- **Framework**: **SvelteKit**
    - **Reason**: 간결한 문법과 뛰어난 성능(Compile-time 프레임워크)을 제공하며, PWA 기능을 통해 모바일 사용자에게 네이티브와 유사한 경험을 제공함. Svelte 고유의 반응성(Reactivity)이 실시간 자산 관리에 매우 적합함.
- **Library**: **Svelte**
- **Styling**: **Vanilla CSS / CSS Modules**
    - **Aesthetics**: 디자인적 우수성을 위해 모던한 Typography(Inter/Gmarket Sans 등)와 부드러운 Glassmorphism 디자인 적용.
- **State Management**: **Svelte Stores**
    - **Reason**: 프레임워크 내장 기능으로 별도의 외부 라이브러리 없이도 강력하고 효율적인 상태 관리가 가능함.

## 2. Backend & Database
- **BaaS**: **Supabase**
    - **Database**: PostgreSQL (강력한 관계형 DB)
    - **Auth**: Supabase Auth (이메일/소셜 로그인 지원)
    - **Real-time**: DB 변경 시 즉각적인 클라이언트 업데이트 지원. 모바일과 PC 간의 실시간 동기화 핵심 기술.

## 3. Infrastructure
- **Deployment**: **Vercel** 또는 **Netlify**
    - **Reason**: SvelteKit과의 원활한 연동 및 글로벌 엣지 네트워크를 통한 빠른 응답 속도 보장.
- **Database Hosting**: **Supabase Cloud**
    - **Reason**: 설정 없이 즉시 사용 가능한 PostgreSQL 서비스 및 넉넉한 무료 배포 사양.

## 4. Key Performance Strategies
- **PWA Support**: 오프라인 접근(선택적) 및 모바일 네이티브 앱과 유사한 경험 제공.
- **Optimized Data Fetching**: Supabase 클라이언트를 사용하여 필요한 데이터만 효율적으로 쿼리.
