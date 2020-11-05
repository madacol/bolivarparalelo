<script lang="ts">
    export let currency: { code: string; symbol: string; name: string; };
    export let showName: boolean = false;
    export let reverseOrder: boolean = false;

    let country_code: string;
    $: country_code = currency.code.substring(0,2);
</script>

<div class="currency" class:reverseOrder>
    {#if showName}
        <span class="code">{currency.name}</span>
        &nbsp;
    {/if}
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

<style>
    .currency {
        display: flex;
        align-items: center;
        margin-bottom: 0.2em;
    }
    .currency.reverseOrder {
        flex-flow: row-reverse;
    }
    .code {
        opacity: 70%;
        line-height: normal;
    }
    .flag {
        display: flex;
        justify-content: center;
        font-size: 1.2em;
        width: 1.2em;
    }
    .flag > img {
        width: 100%;
        border-radius: 0.1em;
    }
</style>