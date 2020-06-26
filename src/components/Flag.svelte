<script>
    export let currency;
    export let group;

    $: country_code = currency.code.substring(0,2);
</script>


<label>
    <input type="radio"
        bind:group={group}
        on:change
        value={currency.code}
    >
    {#if currency.code === "btc"}
        <span>{currency.code.toUpperCase()}</span>
    {:else}
        <img src={`/flags/${country_code}.svg`} alt={`${currency.code}`}>
    {/if}
    <!-- <div>{currency.flag || currency.code.toUpperCase()}</div> -->
</label>

<style>
    label {
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        font-size: 2em;
        width: 1.4em;
        height: 1.4em;
    }
    label > input {
        display: none
    }
    label > input + *{
        cursor: pointer;
        opacity: 50%;
        width: 70%;
        border-radius: 0.1em;
    }
    label > input:checked + *{
        font-size: 1.4em;
        cursor: auto;
        opacity: 100%;
        z-index: 1;
        width: 100%;
    }
    label:hover > input + *{
        font-size: 1.4em;
        width: 100%;
    }

</style>