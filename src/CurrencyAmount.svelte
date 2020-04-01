<script>
    import getHumanRate from './helpers/getHumanRate.js'
    import normalizeNumberSeparators from './helpers/normalizeNumberSeparators.js'

    // Props
    export let handleAmountChange;
    export let amount;
    // Optional Props
    export let buyAmount=null;
    export let sellAmount=null;
    export let className='';
    export let currency=null;
    export let title='';
    export let showBuySell=false;

    $: text = getHumanRate(amount)

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


<div class={`currencyAmount d-flex flex-column flex-wrap ${className}`} {title}>
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
    <input type="text" onfocus="this.select();" on:keyup={handleKeyUp} value={text} size={text.length} />
    {#if showBuySell}
        <span class="buy-sell">{sellAmount}</span>
    {/if}
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
    .buy-sell {
        height: 1.1em;
        font-size: 0.8em;
        opacity: 60%;
        width: 100%;
        text-align: "center";
    }
</style>