<script>
    import Chart from './Chart.svelte';
    import Form from './Form.svelte';
    import Modal from './Modal.svelte';
    import CurrencyAmount from './CurrencyAmount.svelte';
    import getHumanRate from './helpers/getHumanRate.js'

    // Props
    export let rate;
    export let base_currency;
    export let counter_currency;
    export let showBuySell;

    /**********
     * STATES *
     **********/
    let base_amount = 1;
    let counter_amount = base_amount * rate.avg;
    // Reactive States
    $: counter_buy_amount = getHumanRate(base_amount * rate.buy);
    $: counter_sell_amount = getHumanRate(base_amount * rate.sell);
    $: counter_title = `compra: ${counter_buy_amount}\n    venta: ${counter_sell_amount}`
    $: base_buy_amount = getHumanRate(counter_amount / rate.sell);
    $: base_sell_amount = getHumanRate(counter_amount / rate.buy);
    $: base_title = `compra: ${base_buy_amount}\n    venta: ${base_sell_amount}`

    /************
     * HANDLERS *
     ************/
    const handleCounterAmountChange = newAmount => {
        counter_amount = newAmount;
        base_amount = counter_amount / rate.avg;
    }

    const handleBaseAmountChange = newAmount => {
        base_amount = newAmount;
        counter_amount = base_amount * rate.avg;
    }

</script>

<div class="rateCalculator d-flex justify-content-center align-items-end flex-wrap">

    <CurrencyAmount
        className={"reverse"}
        amount={base_amount}
        buyAmount={base_buy_amount}
        sellAmount={base_sell_amount}
        handleAmountChange={handleBaseAmountChange}
        currency={base_currency}
        title={base_title}
        {showBuySell}
    />

    <div class="equal {showBuySell ? 'buy-sell' : ''}">=</div>

    <CurrencyAmount
        amount={counter_amount}
        buyAmount={counter_buy_amount}
        sellAmount={counter_sell_amount}
        handleAmountChange={handleCounterAmountChange}
        currency={counter_currency}
        title={counter_title}
        {showBuySell}
    />

</div>

<style>
    .rateCalculator {
        margin-bottom: 0.5em;
    }
    .equal {
        margin: 0 1em;
        margin-bottom: 0.5em
    }
    .equal.buy-sell {
        margin-bottom: 1.4em
    }
</style>