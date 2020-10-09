<script lang="ts">
    export let currency: { code: string; symbol: string; name: string; };
    export let showName: boolean = false;

    let country_code: string;
    $: country_code = currency.code.substring(0,2);
</script>

<div class="currency">
    <span class="code">{currency.code.toUpperCase()}</span>
    &nbsp;
    <span class="flag">
        {#if currency.code === "btc"}
            <strong>{currency.symbol.toUpperCase()}</strong>
        {:else}
            <img src={`/flags/${country_code}.svg`} alt={`${currency.code}`}>
        {/if}
    </span>
    {#if showName}
        &nbsp;
        <span class="code">{currency.name}</span>
    {/if}
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