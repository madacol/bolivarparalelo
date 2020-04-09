<script>
    import getHumanRate from './helpers/getHumanRate.js'
    import normalizeNumberSeparators from './helpers/normalizeNumberSeparators.js'

    // Props
    export let handleAmountChange;
    export let amount;
    // Optional Props
    export let buyAmount=null;
    export let sellAmount=null;
    export let reverseAlign=false;
    export let fakeCursor=false;
    export let currency=null;
    export let showBuySell=false;

    $: text = getHumanRate(amount)
    $: title = `compra: ${buyAmount}\n    venta: ${sellAmount}`

    // $: attr_name = (amount === 1) ? "name" : "namePlural"

    //Handlers
    function handleKeyUp(e) {
        // Return if these keys where pressed
        if ( ["Tab","Shift","Arrow"].some(key=>e.key.startsWith(key)) ) return;

        // Validate then update amount
        const numberString = normalizeNumberSeparators(e.target.value);
        const parsedNumber = parseFloat(numberString);
        if (parsedNumber) {
            handleAmountChange(parsedNumber);
            e.target.value = numberString;
        }

        // Adapt input size to content
        e.target.size = (e.target.value.length || 1);
    }

</script>


<div class:reverseAlign class="currencyAmount d-flex flex-column flex-wrap" {title}>
    {#if currency}
        <div class="currency d-flex">
            <span class="flag">{@html `${currency.flag || `<strong>${currency.symbol.toUpperCase()}</strong>`}`}</span>
            &nbsp;
            <span class="code">{currency.code.toUpperCase()}</span>
        </div>
    {/if}
    {#if showBuySell}
        <span class="buy-sell">{buyAmount}</span>
    {/if}
    <div class="amount">
        <input type="text" class:fakeCursor onfocus="this.select();" on:keyup={handleKeyUp} value={text} size={text.length || 1} />
    </div>
    {#if showBuySell}
        <span class="buy-sell">{sellAmount}</span>
    {/if}
</div>


<style>
    input {
        font-size: 2em;
        line-height: 1.15;
        background-color: transparent;
        color: white;
        border: 0;
        border-right: 1px solid transparent;
        margin: 0 0.2em;
    }
    .fakeCursor {
        border-right: 1px solid white;
    }
    .amount {
        border: 1px solid var(--gray3);
        border-radius: 0.2em;
    }
    .currencyAmount {
        align-items: flex-start;
    }
    .currencyAmount.reverseAlign {
        align-items: flex-end !important;
    }
    .reverseAlign > .currency {
        flex-flow: row-reverse;
    }
    .code {
        font-size: 1em;
        opacity: 70%;
    }
    .flag {
        font-size: 1.2em;
    }
    .buy-sell {
        height: 1.1em;
        font-size: 0.9em;
        opacity: 70%;
        width: 100%;
        text-align: "center";
    }
</style>