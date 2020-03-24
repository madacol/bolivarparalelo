<script>
    import getHumanRate from './helpers/getHumanRate.js'
    import normalizeNumberSeparators from './helpers/normalizeNumberSeparators.js'

    // Props
    export let handleAmountChange;
    export let amount;
    export let currency;
    // Optional Props
    const {className} = $$props

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


<div class={`d-flex flex-column flex-wrap ${className}`}>
    <div class="currency d-flex">
        <span class="flag">{@html `${currency.flag || `<strong>${currency.symbol.toUpperCase()}</strong>`}`}</span>
        &nbsp;
        <span class="code">{currency.code.toUpperCase()}</span>
    </div>
    <input type="text" onfocus="this.select();" on:keyup={handleInputWidth} on:change={handleChange} value={text} size={text.length} />
</div>


<style>
    div > input {
        font-size: 2em;
        line-height: 1.15;
        background-color: transparent;
        color: white;
        border: 0;
        border-bottom: 1px solid;
    }
    .currency {
        margin-left: 0.3em;
    }
    .reverse {
        align-items: flex-end;
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