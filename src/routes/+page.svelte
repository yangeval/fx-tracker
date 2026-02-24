<script lang="ts">
    import { contracts } from "$lib/stores/contracts";
    import { supabase } from "$lib/supabaseClient";

    // --- 통계 계산 로직 ---
    let stats = $derived.by(() => {
        let buyingAsset = 0; // 운용 자산 ($)
        let holdingAsset = 0; // 보유 자산 ($)
        let realizedProfit = 0; // 실현 수익 (₩)
        let expectedProfit = 0; // 기대 수익 (₩)

        $contracts.forEach((c) => {
            if (c.status === "BUY_ORDER") {
                buyingAsset += Number(c.quantity);
            } else if (c.status === "SELL_ORDER") {
                holdingAsset += Number(c.quantity) * Number(c.buy_price);
                expectedProfit +=
                    (Number(c.target_price) - Number(c.buy_price)) *
                    Number(c.quantity);
            } else if (c.status === "COMPLETED") {
                realizedProfit +=
                    (Number(c.sell_price || 0) - Number(c.buy_price)) *
                    Number(c.quantity);
            }
        });

        return { buyingAsset, holdingAsset, realizedProfit, expectedProfit };
    });

    // --- 거래 추가 로직 ---
    let newContract = $state({
        platform: "토스",
        buy_price: "",
        target_price: "",
        grid_gap: "10",
        quantity: "",
    });

    let nextBuyPrice = $derived(
        Number(newContract.buy_price) - Number(newContract.grid_gap),
    );

    async function addContract() {
        const { error } = await supabase.from("contracts").insert([
            {
                platform: newContract.platform,
                buy_price: Number(newContract.buy_price),
                target_price: Number(newContract.target_price),
                grid_gap: Number(newContract.grid_gap),
                next_buy_price: nextBuyPrice,
                quantity: Number(newContract.quantity),
                status: "BUY_ORDER",
            },
        ]);

        if (error) alert("추가 실패: " + error.message);
        else {
            newContract.buy_price = "";
            newContract.quantity = "";
        }
    }

    // --- 상태 업데이트 로직 ---
    async function updateStatus(
        id: string,
        currentStatus: string,
        buyPrice: number,
        targetPrice: number,
    ) {
        let nextStatus = "";
        let updateData: any = {};

        if (currentStatus === "BUY_ORDER") {
            nextStatus = "SELL_ORDER";
            updateData = { status: nextStatus };
        } else if (currentStatus === "SELL_ORDER") {
            const sellPriceStr = prompt(
                "실제 매도 환율을 입력하세요 (목표가: " + targetPrice + ")",
            );
            if (!sellPriceStr) return;
            nextStatus = "COMPLETED";
            updateData = {
                status: nextStatus,
                sell_price: Number(sellPriceStr),
            };
        }

        const { error } = await supabase
            .from("contracts")
            .update(updateData)
            .eq("id", id);
        if (error) alert("업데이트 실패: " + error.message);
    }
</script>

<div class="container">
    <header class="stats-header">
        <h1>FX-Tracker</h1>
        <div class="stats-grid">
            <div class="stat-card">
                <span class="label">운용 자산 (매수대기)</span>
                <span class="value">$ {stats.buyingAsset.toLocaleString()}</span
                >
            </div>
            <div class="stat-card">
                <span class="label">보유 자산 (매수완료)</span>
                <span class="value"
                    >₩ {stats.holdingAsset.toLocaleString()}</span
                >
            </div>
            <div class="stat-card highlight">
                <span class="label">실현 수익</span>
                <span class="value success"
                    >₩ {stats.realizedProfit.toLocaleString()}</span
                >
            </div>
            <div class="stat-card">
                <span class="label">기대 수익</span>
                <span class="value warning"
                    >₩ {stats.expectedProfit.toLocaleString()}</span
                >
            </div>
        </div>
    </header>

    <section class="quick-entry">
        <div class="section-title">
            <h2>빠른 거래 추가</h2>
            <span class="grid-tip">다음 타점: {nextBuyPrice || 0}</span>
        </div>
        <div class="entry-form">
            <select bind:value={newContract.platform}>
                <option>토스</option>
                <option>스위치원</option>
                <option>카뱅</option>
            </select>
            <input
                type="number"
                placeholder="매수가"
                bind:value={newContract.buy_price}
            />
            <input
                type="number"
                placeholder="목표가"
                bind:value={newContract.target_price}
            />
            <input
                type="number"
                placeholder="수량 ($)"
                bind:value={newContract.quantity}
            />
            <button class="btn-primary" onclick={addContract}>추가</button>
        </div>
    </section>

    <section class="active-list">
        <h2>진행 중인 계약</h2>
        <div class="contracts-grid">
            {#each $contracts.filter((c) => c.status !== "COMPLETED") as c}
                <div class="contract-card {c.status.toLowerCase()}">
                    <div class="card-header">
                        <span class="platform-tag">{c.platform}</span>
                        <span class="status-tag"
                            >{c.status === "BUY_ORDER"
                                ? "매수 주문"
                                : "매도 주문"}</span
                        >
                    </div>
                    <div class="card-body">
                        <div class="price-row">
                            <div class="price-item">
                                <span class="label">매수가</span>
                                <span class="price"
                                    >{c.buy_price.toLocaleString()}</span
                                >
                            </div>
                            <div class="arrow">→</div>
                            <div class="price-item">
                                <span class="label">목표가</span>
                                <span class="price"
                                    >{c.target_price.toLocaleString()}</span
                                >
                            </div>
                        </div>
                        <div class="info-row">
                            <span>수량: ${c.quantity.toLocaleString()}</span>
                            <span class="next-buy"
                                >다음 타점: {c.next_buy_price}</span
                            >
                        </div>
                    </div>
                    <div class="card-actions">
                        {#if c.status === "BUY_ORDER"}
                            <button
                                class="btn-action"
                                onclick={() =>
                                    updateStatus(
                                        c.id,
                                        c.status,
                                        c.buy_price,
                                        c.target_price,
                                    )}>매수 체결</button
                            >
                        {:else}
                            <button
                                class="btn-action success"
                                onclick={() =>
                                    updateStatus(
                                        c.id,
                                        c.status,
                                        c.buy_price,
                                        c.target_price,
                                    )}>매도 완료</button
                            >
                        {/if}
                    </div>
                </div>
            {/each}
        </div>
    </section>
</div>

<style>
    .stats-header {
        margin-bottom: 24px;
        padding-top: 8px;
    }
    h1 {
        font-size: 24px;
        margin-bottom: 16px;
    }

    .stats-grid {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 12px;
    }

    .stat-card {
        background: var(--card-bg);
        padding: 12px;
        border-radius: var(--radius);
        box-shadow: var(--shadow);
        display: flex;
        flex-direction: column;
    }

    .stat-card.highlight {
        border: 2px solid var(--success);
    }

    .stat-card .label {
        font-size: 11px;
        color: var(--text-muted);
        margin-bottom: 4px;
    }
    .stat-card .value {
        font-size: 16px;
        font-weight: 700;
    }
    .value.success {
        color: var(--success);
    }
    .value.warning {
        color: var(--warning);
    }

    .section-title {
        display: flex;
        justify-content: space-between;
        align-items: baseline;
        margin-bottom: 12px;
    }
    h2 {
        font-size: 18px;
    }
    .grid-tip {
        font-size: 12px;
        color: var(--primary);
        font-weight: 600;
    }

    .quick-entry {
        margin-bottom: 28px;
    }
    .entry-form {
        display: grid;
        grid-template-columns: 80px 1fr 1fr;
        gap: 8px;
    }
    .entry-form input,
    .entry-form select {
        padding: 10px;
        font-size: 14px;
    }
    .entry-form button {
        grid-column: span 3;
        padding: 12px;
        font-weight: 600;
        background: var(--primary);
        color: white;
    }

    .contracts-grid {
        display: flex;
        flex-direction: column;
        gap: 12px;
        margin-top: 12px;
    }

    .contract-card {
        background: var(--card-bg);
        padding: 16px;
        border-radius: var(--radius);
        box-shadow: var(--shadow);
        border-left: 4px solid var(--primary);
    }

    .contract-card.sell_order {
        border-left-color: var(--success);
    }

    .card-header {
        display: flex;
        justify-content: space-between;
        margin-bottom: 12px;
    }
    .platform-tag {
        background: #f1f5f9;
        padding: 2px 8px;
        border-radius: 4px;
        font-size: 12px;
        font-weight: 600;
    }
    .status-tag {
        font-size: 12px;
        color: var(--text-muted);
    }

    .price-row {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 12px;
    }
    .price-item {
        display: flex;
        flex-direction: column;
        align-items: center;
    }
    .price-item .label {
        font-size: 10px;
        color: var(--text-muted);
    }
    .price-item .price {
        font-size: 18px;
        font-weight: 700;
    }
    .arrow {
        color: var(--text-muted);
        font-size: 20px;
    }

    .info-row {
        display: flex;
        justify-content: space-between;
        font-size: 13px;
        color: var(--text-muted);
        margin-bottom: 12px;
    }
    .next-buy {
        color: var(--primary);
        font-weight: 600;
    }

    .btn-action {
        width: 100%;
        padding: 10px;
        font-weight: 600;
        background: #f1f5f9;
        color: var(--text-main);
    }
    .btn-action.success {
        background: var(--success);
        color: white;
    }
</style>
