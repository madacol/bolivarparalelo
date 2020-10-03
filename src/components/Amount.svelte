<script lang="ts">
    import getHumanRate from '../helpers/getHumanRate.js';
    import normalizeNumberSeparators from '../helpers/normalizeNumberSeparators.js';
    import { fakeCursor } from "../stores";

    // Props
    export let handleAmountChange: (newAmount: number)=>void;
    export let amounts: {avg: number, buy: number, sell: number};
    // Optional Props
    export let showBuySell: boolean = false;

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
    <span on:click|stopPropagation>{buyText}</span>
{/if}
<label class="amount" {title}>
    <input
        type="text"
        class:fakeCursor={$fakeCursor}
        on:click|stopPropagation
        on:focus={e=>e.target.select()}
        on:keyup={handleKeyUp}
        value={avgText}
        size={avgText.length || 1}
    />
</label>
{#if showBuySell}
    <span on:click|stopPropagation>{sellText}</span>
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
    }
    span {
        height: 1.1em;
        font-size: 0.9em;
        opacity: 80%;
        cursor: text;
    }
</style>