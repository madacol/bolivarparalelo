<script lang="ts">
    import Amount from "./Amount.svelte";
    import Currency from "./Currency.svelte";

    // Props
    export let handleAmountChange: (newAmount: number)=>void;
    export let amounts: {avg: number, buy: number, sell: number};
    // Optional Props
    export let reverseAlign: boolean = false;
    export let showBuySell: boolean = false;
    export let currency = null;

    $: title = `compra: ${amounts.buy}\n    venta: ${amounts.sell}`

</script>


<div class:reverseAlign class="currencyAmount" {title}>
    {#if currency}
        <Currency {currency}/>
    {/if}
    <Amount
        {handleAmountChange}
        {amounts}
        {showBuySell}
    />
</div>


<style>
    .currencyAmount {
        display: flex;
        align-items: flex-start;
        flex-direction: column;
        flex-wrap: wrap;
    }
    .currencyAmount.reverseAlign {
        align-items: flex-end !important;
    }
    .reverseAlign > :global(.currency) {
        flex-flow: row-reverse;
    }
</style>