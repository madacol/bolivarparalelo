<script>
    import CurrencyAmount from './CurrencyAmount.svelte';
    import getHumanRate from '../helpers/getHumanRate.js';
    import { fakeCursor } from '../stores.js';


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
    $: counter_buy_amount = getHumanRate(base_amount * rates.buy);
    $: counter_sell_amount = getHumanRate(base_amount * rates.sell);
    $: base_buy_amount = getHumanRate(counter_amount / rates.sell);
    $: base_sell_amount = getHumanRate(counter_amount / rates.buy);


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
        amount={base_amount}
        buyAmount={base_buy_amount}
        sellAmount={base_sell_amount}
        handleAmountChange={handleBaseAmountChange}
        currency={base_currency}
        {showBuySell}
        fakeCursor={$fakeCursor}
    />

    <div class="equal {showBuySell ? 'buy-sell' : ''}">=</div>

    <CurrencyAmount
        amount={counter_amount}
        buyAmount={counter_buy_amount}
        sellAmount={counter_sell_amount}
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