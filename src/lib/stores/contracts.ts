import { writable } from 'svelte/store';
import { supabase } from '$lib/supabaseClient';

export interface Contract {
    id: string;
    user_id: string;
    platform: string;
    buy_price: number;
    target_price: number;
    quantity: number;
    status: 'PENDING' | 'HOLDING' | 'SOLD';
    created_at: string;
    updated_at: string;
}

// 계약 목록을 담는 writable store
export const contracts = writable<Contract[]>([]);

// 서버에서 계약 목록을 가져와 store를 업데이트하는 함수
export const fetchContracts = async () => {
    const { data, error } = await supabase
        .from('contracts')
        .select('*')
        .order('created_at', { ascending: false });

    if (error) {
        console.error('계약 목록을 가져오는 중 오류 발생:', error);
        return;
    }

    contracts.set(data || []);
};

// 실시간 DB 변경 사항을 구독하고 store를 갱신하는 함수
export const subscribeToContracts = () => {
    const subscription = supabase
        .channel('public:contracts')
        .on(
            'postgres_changes',
            { event: '*', schema: 'public', table: 'contracts' },
            (payload) => {
                console.log('데이터 변경 감지:', payload);
                fetchContracts(); // 데이터 변경 시 전체 다시 명세 (단순화된 방식)
            }
        )
        .subscribe();

    // 구독 해제 함수 반환
    return () => {
        supabase.removeChannel(subscription);
    };
};
