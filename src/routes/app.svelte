<script>
    import Rate from '../components/Rate.svelte';
    import { onMount } from 'svelte';
    import { fakeCursor } from '../stores';
    import { hashLS } from '../localStorageStore.js';
    import { FAKE_CURSOR_BLINK_DELAY } from '../CONSTANTS.js';


    /*************
     * Constants *
     *************/
    const defaultHash = `ves,usd,1;ves,eur;ves,usd_0,160` // 160 = 24*7 (hours in a week)
    const bitcoin_currency = {
        id: 0,
        code: "btc",
        symbol: "₿",
        name: "Bitcoin",
        namePlural: "Bitcoins",
    }


    /*********
     * Setup *
     *********/
    let isTutorial = false;
    let intervalID;
    let hash;
    // Check if hash is empty
    const isUsingHashUrl = !!window.location.hash
    if (isUsingHashUrl) {
        // Set hash to default
        hash = window.location.hash.slice(1);
    } else {
        hash = $hashLS || defaultHash;
        if (!$hashLS) enableTutorial(false);
    }
    let currencies = [];
    let bitcoin_rate;
    // Get rates from hash
    let rateHashes = hash.split(';');
    // Filter removed rates and update hash or Local Storage
    $: if (isUsingHashUrl) {
        window.location.hash = rateHashes.filter(x=>x).join(';');
    } else {
        $hashLS = rateHashes.filter(x=>x).join(';');
    }

    /******************
     * Setup Tutorial *
     ******************/
    $: bodyHandler = isTutorial ? disableTutorial : null;
    $: demoHandler = isTutorial ? disableTutorial : enableTutorial;

    // Functions
    function enableTutorial(fireImmediately=true) {
        intervalID = setInterval(()=>{ $fakeCursor = !$fakeCursor }, FAKE_CURSOR_BLINK_DELAY);
        isTutorial = true;
    }
    function disableTutorial() {
        clearInterval(intervalID);
        $fakeCursor = false;
        isTutorial = false;
    }

    /**************
     * LifeCycles *
     **************/
    onMount(async () => {
        const response = await fetch('/api/currencies');
        currencies = [...(await response.json()), bitcoin_currency]
    })
    onMount(async () => {
        const response = await fetch('/api/rate/usd/btc');
        bitcoin_rate = await response.json();
    })

    /************
     * HANLDERS *
     ************/
    function AddRate() {
        rateHashes = [...rateHashes, ','];
    }

</script>


<svelte:head>
	<title>Bolivar Paralelo</title>
</svelte:head>


<nav class="navbar navbar-expand-lg navbar-dark">
    <a href="/" class="navbar-brand">Bolívar Paralelo</a>
    <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarSupportedContent" aria-controls="navbarToggleExternalContent" aria-expanded="false" aria-label="Toggle navigation">
    <span class="navbar-toggler-icon"></span>
    </button>
    <div class="justify-content-end collapse navbar-collapse" id="navbarSupportedContent">
    <ul class="navbar-nav">
        <li class="nav-item">
            <span on:click={demoHandler}>
                {#if isTutorial}
                    Cancelar demo
                {:else}
                    Demo
                {/if}
            </span>
        </li>
        <div class="border"></div>
        <li class="nav-item">
            <a href="/classic">Ver versión clásica</a>
        </li>
    </ul>
</nav>


<div id="body" on:click={bodyHandler} on:keydown={bodyHandler}>
    {#each rateHashes as rateHash}
        {#if rateHash}
            <Rate bind:rateHash {currencies} />
        {/if}
    {/each}
    <div id="newRate">
        <button on:click={AddRate}>
            Agregar Tasa o Gráfico
        </button>
    </div>
</div>

<nav class="navbar d-flex justify-content-between">
    <div></div>
    {#if bitcoin_rate}
        <div id="bitcoin" class="navbar-brand">Bitcoin: {bitcoin_rate.avg} $</div>
    {/if}
    <div>
        <a href="https://twitter.com/bolivarparalel0">
            <img alt="twitter icon" src="/icons/Twitter_Social_Icon_Circle_White.png" width="40" height="40">
        </a>
        <a href="https://github.com/madacol/bolivarparalelo">
            <img alt="github icon" src="/icons/GitHub-Mark-Light-64px.png" width="40" height="40">
        </a>
    </div>
</nav>

<style>
    nav{
        background-color: var(--navBackgroundColor);
        min-height: 60px;
        font-size: calc(13px + 0.3vw);
    }
    nav span,
    nav a {
        font-size: 1.2em;
        cursor: pointer;
        white-space: nowrap;
        color: white;
    }
    #body {
        display: flex;
        flex-direction: column;
        height: calc(100vh - 120px);
        overflow: auto;
        line-height: 1.15;
        padding: 1em;
        font-size: calc(10px + 0.9vw);
    }
    #bitcoin {
        font-size: 1.2em;
    }
    #navbarSupportedContent ul li {
        position: relative;
        margin: 0 1em;
    }
    #newRate {
        align-self: center;
        width: 100%;
        max-width: 1100px;
    }
    #newRate > button {
        cursor: pointer;
        padding: 0.5em;
        width: 100%;
        max-width: 1100px;
        border: 1px dashed var(--gray3);
        border-radius: 1em;
        margin-bottom: 1em;
        min-height: 6em;
        background-color: transparent;
        color: white;
    }
    #newRate > button:focus {
        outline: 0;
        box-shadow: 0 0 0 .1em var(--gray3);
    }
    #newRate > button:hover {
        background-color: var(--gray1);
    }
</style>