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

    // States
    let base_amount = 1;
    let counter_amount = base_amount * rate;

    const handleCounterAmountChange = newAmount => {
        counter_amount = newAmount;
        base_amount = counter_amount / rate;
    }

    const handleBaseAmountChange = newAmount => {
        base_amount = newAmount;
        counter_amount = base_amount * rate;
    }

</script>

<div class="rateCalculator d-flex justify-content-center align-items-end flex-wrap">

    <CurrencyAmount
        className={"reverse"}
        amount={base_amount}
        handleAmountChange={handleBaseAmountChange}
        currency={base_currency}
    />

    <div class="equal">=</div>

    <CurrencyAmount
        amount={counter_amount}
        handleAmountChange={handleCounterAmountChange}
        currency={counter_currency}
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
</style>