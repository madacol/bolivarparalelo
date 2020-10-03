<script lang="ts">
    import Amount from "./Amount.svelte";
    import Currency from "./Currency.svelte";
    import CheckboxToggle from "./CheckboxToggle.svelte";

    export let latest_bitcoin_rates: any[];    // price of 1 BTC in every currency

    let base_rate = latest_bitcoin_rates.find( ({currency: {code}})=>code==="usd" );
    let amount = 1;
    let showBuySell = false;

    let rates: ArrayLike<{amounts: {avg: number, buy: number, sell: number}, currency: any, handleAmountChange: (newAmount: number)=>void}>;
    $: rates = latest_bitcoin_rates.map(rate => ({
        amounts: {
            avg: rate.avg * amount / base_rate.avg,
            buy: rate.buy * amount / base_rate.sell,
            sell: rate.sell * amount / base_rate.buy,
        },
        currency: rate.currency,
        handleAmountChange: handleAmountChange_Builder(rate)
    }))

    function handleAmountChange_Builder(rate) {
        return function (newAmount: number) {
            base_rate = rate;
            amount = newAmount;
        }
    }

</script>

<main>
    <div class="latestRates">
        {#each rates as {currency, amounts, handleAmountChange}}
            <div
                class:highlight={currency===base_rate.currency}
                class="currencyAmount"
                on:click={()=>handleAmountChange(1)}
            >
                <Amount
                    {amounts}
                    {handleAmountChange}
                    {showBuySell}
                />
                &nbsp;
                <Currency
                    {currency}
                />
            </div>
        {/each}
    </div>
    <div class="settings">
        <CheckboxToggle
        bind:checked={showBuySell}
        label={"Tasas de compra y venta:"}
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
        justify-content: end;
        align-items: center;
        padding: 0.5em 1em;
        margin: 0.4em;
        border-radius: 1em;
        background-color: var(--gray1);
        cursor: pointer;
    }
    .currencyAmount:hover, .currencyAmount.highlight {
        background-color: var(--gray2);
    }
    .settings {
        border-radius: 0 0 1em 1em;
        width: 100%;
        padding: 0.5em;
        background-color: var(--gray2);
    }
</style>