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

</script>


<div class:reverseAlign class="currencyAmount">
    {#if currency}
        <Currency {currency}/>
    {/if}
    <div class="amount">
        <Amount
            {handleAmountChange}
            {amounts}
            {showBuySell}
        />
    </div>
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
    .amount {
        display: flex;
        flex-direction: column;
        align-items: stretch;
    }
</style>