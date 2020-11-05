<script lang="ts">
    import getHumanRate from '../helpers/getHumanRate.js';
    import normalizeNumberSeparators from '../helpers/normalizeNumberSeparators.js';
    import { fakeCursor } from "../stores";

    // Props
    export let handleAmountChange: (newAmount: number)=>void;
    export let amounts: {avg: number, buy: number, sell: number};
    // Optional Props
    export let showBuySell: boolean = false;
    export let showLabels: boolean = false;

    $: avgText = getHumanRate(amounts.avg);
    $: buyText = getHumanRate(amounts.buy);
    $: sellText = getHumanRate(amounts.sell);

    $: title = `compra: ${buyText}\n    venta: ${sellText}`

    // $: attr_name = (amounts.avg === 1) ? "name" : "namePlural"

    //Handlers
    function handleKeyUp(e) {
        // Return if these keys where pressed
        if ( ["Tab","Shift","Arrow"].some(key=>e.key.startsWith(key)) ) return;

        // Validate then update amount
        const numberString = normalizeNumberSeparators(e.target.value);
        const parsedNumber = parseFloat(numberString);
        if (parsedNumber && parsedNumber !== amounts.avg) {
            handleAmountChange(parsedNumber);
        }

        // Adapt input size to content
        e.target.size = (e.target.value.length || 1);
    }
</script>


{#if showBuySell}
    <div class="buysell">
        {#if showLabels}
            <span class="label">compra</span>
        {/if}
        <span class="amount" on:click|stopPropagation>{buyText}</span>
    </div>
{/if}
<label {title}>
    <input
        type="text"
        class:fakeCursor={$fakeCursor}
        on:click|stopPropagation
        on:focus={e=>e.currentTarget.select()}
        on:keyup={handleKeyUp}
        value={avgText}
        size={avgText.length || 1}
    />
</label>
{#if showBuySell}
    <div class="buysell">
        {#if showLabels}
            <span class="label">venta</span>
        {/if}
        <span class="amount" on:click|stopPropagation>{sellText}</span>
    </div>
{/if}

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
    input.fakeCursor {
        border-right: 1px solid white;
    }
    label {
        border: 1px solid var(--gray3);
        border-radius: 0.2em;
        text-align: end;
        cursor: text;
        margin: 0 0.6em;
    }
    .buysell {
        display: flex;
        flex-direction: column;
        align-items: center;
        font-size: 0.9em;
    }
    .buysell > .label {
        /* border-bottom: var(--gray5) solid 1px; */
        /* padding-bottom: 0.4em; */
        font-size: 0.9em;
        opacity: 60%;
        margin-bottom: 0.5em;
    }
    .buysell > .amount {
        height: 1.1em;
        cursor: text;
    }
    .buysell > .label + .amount {
        font-weight: bold;
    }
</style>