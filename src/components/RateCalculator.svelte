<script>
    import CurrencyAmount from './CurrencyAmount.svelte';

    /*********
     * PROPS *
     *********/
    export let rates;
    export let base_currency;
    export let counter_currency;
    export let showBuySell;

    /**********
     * STATES *
     **********/
    let base_amount = 1;
    const _base_amount = ()=>base_amount; // This is needed so that the next statement does not consider `base_amount` as a dependency
    $: counter_amount = _base_amount() * rates.avg; // only re-run this when `rates.avg` changes
    // Reactive Declarations
    $: counter_amounts = {
        avg: counter_amount,
        buy: base_amount * rates.buy,
        sell: base_amount * rates.sell,
    }
    $: base_amounts = {
        avg: base_amount,
        buy: counter_amount / rates.sell,
        sell: counter_amount / rates.buy,
    }


    /************
     * HANDLERS *
     ************/
    function handleCounterAmountChange (newAmount) {
        counter_amount = newAmount;
        base_amount = counter_amount / rates.avg;
    }

    function handleBaseAmountChange (newAmount) {
        base_amount = newAmount;
        counter_amount = base_amount * rates.avg;
    }

</script>

<div class="rateCalculator">

    <CurrencyAmount
        reverseAlign={true}
        amounts={base_amounts}
        handleAmountChange={handleBaseAmountChange}
        currency={base_currency}
        {showBuySell}
    />

    <div class="equal {showBuySell ? 'buy-sell' : ''}">=</div>

    <CurrencyAmount
        amounts={counter_amounts}
        handleAmountChange={handleCounterAmountChange}
        currency={counter_currency}
        {showBuySell}
    />

</div>

<style>
    .rateCalculator {
        display: flex;
        justify-content: center;
        align-items: flex-end;
        flex-wrap: wrap;
        font-size: 0.9em;
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