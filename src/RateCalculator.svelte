<script>
    import Chart from './Chart.svelte';
    import Form from './Form.svelte';
    import Modal from './Modal.svelte';

    // Props
    export let rate;
    export let base_currency;
    export let counter_currency;

    // Constants
    const _1Hms = 1000*3600;
    const SIGNIFICANT_DIGITS_TO_SHOW = 4;
    const decimalSeparator = (1.1).toLocaleString().substring(1, 2);
    const thousandSeparator = (10000).toLocaleString().substring(2, 3);

    Number.prototype.humanRate = function() { return this.toLocaleString(navigator.language, {maximumSignificantDigits: SIGNIFICANT_DIGITS_TO_SHOW}) }

    // States
    let base_amount = 1;
    let counter_amount = base_amount * rate;
    $: counter_text = counter_amount.humanRate();
    $: base_text = base_amount.humanRate();

    const parseNumberString = text => {
        if (!text) return 0
        const textNormalized = text
                                .split(thousandSeparator).join('')
                                .split(decimalSeparator).join('.')
        return parseFloat(textNormalized)
    }

    const handleCounterAmount = e => {
        counter_amount = parseNumberString(e.target.value)
        e.target.size = counter_amount.humanRate().length
        base_amount = counter_amount / rate
    }

    const handleBaseAmount = e => {
        base_amount = parseNumberString(e.target.value)
        e.target.size = base_amount.humanRate().length
        counter_amount = base_amount * rate
    }

    const handleInputWidth = e => {
        e.target.size=e.target.value.length || 1
    }

</script>

    <div class="d-flex justify-content-center align-items-center flex-wrap">
        <div class="monto-label">
            <input class="monto" type="text" on:keyup={handleInputWidth} on:change={handleBaseAmount} value={base_text} size={base_text.length} />
            {@html base_currency.name.replace(' ','<br>')}
        </div>
        <div class="monto-label ml-2">=</div>
        <div class="d-flex justify-content-center flex-wrap mx-2 mx-md-4">
            <input class="monto" type="text" on:keyup={handleInputWidth} on:change={handleCounterAmount} value={counter_text} size={counter_text.length} />
            <!-- <input type="text" on:keyup={e=>counter_amount=e.target.value} value={counter_amount} size={counter_amount.length || 1} /> -->
            <div class="align-self-center monto-label mx-2"> {@html counter_currency.namePlural.replace(' ','<br>')}</div>
        </div>
    </div>

<style>
    .monto {
        font-size: calc(10px + 3vw);
        line-height: 1.15;
        background-color: transparent;
        color: white;
        border: 0;
        border-bottom: 1px solid;
        min-width:4px;
    }
    .monto-label {
        font-size: calc(10px + 1vw);
        line-height: 1.15;
    }
</style>