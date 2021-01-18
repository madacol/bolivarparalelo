<script lang="ts">
    import Amount from "./Amount.svelte";
    import Currency from "./Currency.svelte";
    import CheckboxToggle from "./CheckboxToggle.svelte";
    import { createEventDispatcher } from "svelte";
    const dispatch = createEventDispatcher();

    export let latestRatesConfig: { base_currency_code: string; showBuySell: boolean; };
    export let latest_bitcoin_rates: any[];    // price of 1 BTC in every currency

    let base_rate = latest_bitcoin_rates.find( ({currency: {code}})=>code===latestRatesConfig.base_currency_code );
    let amount = 1;
    $: showBuySell = latestRatesConfig.showBuySell;

    let rates: ArrayLike<{amounts: {avg: number, buy: number, sell: number}, currency: any, handleAmountChange: (newAmount: number)=>void}>;
    $: rates = latest_bitcoin_rates.map(rate => {
        const buy = rate.buy * amount / base_rate.sell;
        const sell = rate.sell * amount / base_rate.buy;
        const avg = (buy + sell) / 2;
        return ({
            amounts: { avg, buy, sell },
            currency: rate.currency,
            handleAmountChange: handleAmountChange_Builder(rate)
        })
    })

    function handleAmountChange_Builder(rate: { currency: { code: any; }; }) {
        return function (newAmount: number) {
            base_rate = rate;
            latestRatesConfig.base_currency_code = rate.currency.code;
            amount = newAmount;
            dispatch('change');
        }
    }

</script>

<main>
    <div class="latestRates">
        {#each rates as {currency, amounts, handleAmountChange}}
            <div
                class:highlight={currency===base_rate.currency}
                class:reverseOrder={showBuySell}
                class="currencyAmount"
                on:click={()=>handleAmountChange(1)}
            >
                <Currency
                    {currency}
                    showName={!showBuySell}
                    reverseOrder={!showBuySell}
                />
                &nbsp;
                <div class:alignAround={showBuySell} class="amount">
                    <Amount
                        {amounts}
                        {handleAmountChange}
                        {showBuySell}
                        showLabels={true}
                    />
                </div>
            </div>
        {/each}
    </div>
    <div class="settings">
        <CheckboxToggle
            bind:checked={latestRatesConfig.showBuySell}
            label={"Tasas de compra y venta:"}
            on:change
        />
    </div>
</main>

<style>
    main {
        font-size: 0.7em;
        text-align: center;
        width: 100%;
        max-width: 1100px;
        border: 1px solid var(--gray3);
        border-radius: 1em;
        margin-bottom: 1em;
        position: relative;
        display: flex;
        flex-direction: column;
        align-items: center;
    }
    .latestRates {
        padding: 0.7em;
    }
    .currencyAmount {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 0.5em 1em;
        margin: 0.4em;
        border-radius: 1em;
        background-color: var(--gray1);
        cursor: pointer;
    }
    .currencyAmount.reverseOrder {
        flex-flow: row-reverse;
    }
    .currencyAmount:hover, .currencyAmount.highlight {
        background-color: var(--gray2);
    }
    .amount {
        display: flex;
        align-items: center;
    }
    .amount.alignAround {
        width: 100%;
        justify-content: space-around;
    }
    .settings {
        border-radius: 0 0 1em 1em;
        width: 100%;
        padding: 0.5em;
        background-color: var(--gray2);
    }
</style>