<script>
    import getHumanRate from './helpers/getHumanRate.js'
    import normalizeNumberSeparators from './helpers/normalizeNumberSeparators.js'

    // Props
    export let handleAmountChange;
    export let amount;
    // Optional Props
    const {
        className,
        currency,
        title,
    } = $$props

    $: text = getHumanRate(amount)

    // $: attr_name = (amount === 1) ? "name" : "namePlural"

    //Handlers
    const handleInputWidth = e => e.target.size = (e.target.value.length || 1)

    const handleChange = e => {
        const numberString = normalizeNumberSeparators(e.target.value);
        const parsedNumber = parseFloat(numberString);
        let newAmount;
        if (parsedNumber) {
            newAmount = parsedNumber;
            e.target.value = numberString;
        } else {
            newAmount = 1;
            e.target.value = 1;
        }
        handleAmountChange(newAmount);
    }

</script>


<div class={`currencyAmount d-flex flex-column flex-wrap ${className || ''}`} {title}>
    {#if currency}
        <div class="currency d-flex">
            <span class="flag">{@html `${currency.flag || `<strong>${currency.symbol.toUpperCase()}</strong>`}`}</span>
            &nbsp;
            <span class="code">{currency.code.toUpperCase()}</span>
        </div>
    {/if}
    <input type="text" onfocus="this.select();" on:keyup={handleInputWidth} on:change={handleChange} value={text} size={text.length} />
</div>


<style>
    div > input {
        font-size: 2em;
        line-height: 1.15;
        background-color: transparent;
        color: white;
        border: 1px solid var(--gray3);
        border-radius: 0.2em;
        padding: 0 0.2em;
    }
    .currencyAmount {
        align-items: flex-start;
    }
    .currencyAmount.reverse {
        align-items: flex-end !important;
    }
    .reverse > .currency {
        flex-flow: row-reverse;
    }
    .code {
        font-size: 1em;
        opacity: 70%;
    }
    .flag {
        font-size: 1.2em;
    }
</style>