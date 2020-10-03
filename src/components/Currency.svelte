<script lang="ts">
    export let currency: { code: string; symbol: string; };

    let country_code: string;
    $: country_code = currency.code.substring(0,2);
</script>

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

<style>
    .currency {
        display: flex;
        align-items: center;
        margin-bottom: 0.2em;
    }
    .code {
        opacity: 70%;
        line-height: normal;
    }
    .flag {
        display: flex;
        align-items: center;
        font-size: 1.2em;
        width: 1.2em;
    }
    .flag > img {
        width: 100%;
        border-radius: 0.1em;
    }
</style>