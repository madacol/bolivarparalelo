<script>
    import getHumanRate from '../helpers/getHumanRate.js'
    import normalizeNumberSeparators from '../helpers/normalizeNumberSeparators.js'

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
    $: country_code = currency.code.substring(0,2);

    // $: attr_name = (amount === 1) ? "name" : "namePlural"

    //Handlers
    function handleKeyUp(e) {
        // Return if these keys where pressed
        if ( ["Tab","Shift","Arrow"].some(key=>e.key.startsWith(key)) ) return;

        // Validate then update amount
        const numberString = normalizeNumberSeparators(e.target.value);
        const parsedNumber = parseFloat(numberString);
        if (parsedNumber && parsedNumber !== amount) {
            handleAmountChange(parsedNumber);
        }

        // Adapt input size to content
        e.target.size = (e.target.value.length || 1);
    }

</script>


<div class:reverseAlign class="currencyAmount" {title}>
    {#if currency}
        <div class="currency">
            <span class="flag">
                {#if currency.code === "btc"}
                    <strong>{currency.symbol.toUpperCase()}</strong>
                {:else}
                    <img src={`/flags/${country_code}.svg`} alt={`${currency.code}`}>
                {/if}
            </span>
            &nbsp;
            <span class="code">{currency.code.toUpperCase()}</span>
        </div>
    {/if}
    {#if showBuySell}
        <span class="buy-sell">{buyAmount}</span>
    {/if}
    <div class="amount">
        <input type="text" class:fakeCursor onfocus="this.select();" on:keyup={handleKeyUp} value={text} size={text.length || 1} data-hj-whitelist />
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
        display: flex;
        align-items: flex-start;
        flex-direction: column;
        flex-wrap: wrap;
    }
    .currencyAmount.reverseAlign {
        align-items: flex-end !important;
    }
    .currency {
        display: flex;
        align-items: center;
        margin-bottom: 0.2em;
    }
    .reverseAlign > .currency {
        flex-flow: row-reverse;
    }
    .code {
        font-size: 1em;
        opacity: 70%;
    }
    .flag {
        display: flex;
        align-items: center;
        font-size: 1.2em;
        width: 1.2em;
    }
    .flag > img{
        width: 100%;
        border-radius: 0.1em;
    }
    .buy-sell {
        height: 1.1em;
        font-size: 0.9em;
        opacity: 70%;
        width: 100%;
        text-align: "center";
    }
</style>