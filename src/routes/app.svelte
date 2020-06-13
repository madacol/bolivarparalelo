<script context="module">


    /**************
     * Currencies *
     **************/
    async function getCurrencies() {
        const BITCOIN_CURRENCY = {
            id: 0,
            code: "btc",
            symbol: "₿",
            name: "Bitcoin",
            namePlural: "Bitcoins",
        }
        const response = await this.fetch('/api/currencies');
        const currencies = await response.json();
        currencies.push(BITCOIN_CURRENCY);

        return currencies;
    }


    /****************
     * Bitcoin rate *
     ****************/
    async function getBitcoinRate() {
        const response = await this.fetch('/api/rate/usd/btc');
        const bitcoin_rate = await response.json();
        bitcoin_rate.avg = (bitcoin_rate.buy + bitcoin_rate.sell) / 2

        return bitcoin_rate;
    }


    /**********************
     * Get Layout's Rates *
     **********************/
    import getRateData from '../helpers/getRateData.js'
    import { _1H_in_ms, _1W_in_ms } from '../CONSTANTS.js'
    import { decodeLayout } from '../helpers/layoutEncoding.js'
    function getRates(layoutRaw) {
        let layout, isTutorial;
        if (layoutRaw) {
            layout = decodeLayout(layoutRaw);
            isTutorial = true
        } else {
            // Default layout
            layout = [
                {params: {counter_currency_code: "ves", base_currency_code: "usd"}, showType: 0, showBuySell: true},
                {params: {counter_currency_code: "ves", base_currency_code: "eur"}, showType: 0, showBuySell: false},
                {params: {counter_currency_code: "ves", base_currency_code: "usd", timeRange: {start: (Date.now()-_1W_in_ms), end: Date.now()}}, showType: 0, showBuySell: false},
            ]
        }
        return Promise.all(
            layout.map(
                async rateLayout => {
                    const {params: {counter_currency_code, base_currency_code, timeRange}} = rateLayout;
                    let start, end;
                    if (timeRange) ({start, end} = timeRange);
                    const data = await getRateData.call(this, counter_currency_code, base_currency_code, start, end);
                    return {...rateLayout, data};
                }
            )
        )
    }

    /**
     * Preload `bitcoin_rate` and `currencies`
     */
    export async function preload(page, session) {
        const getBitcoinRatePromise = getBitcoinRate.apply(this)
        const getCurrenciesPromise = getCurrencies.apply(this)
        const getRatesPromise = getRates.apply(this, session.layout)
        return {
            bitcoin_rate: await getBitcoinRatePromise,
            currencies: await getCurrenciesPromise,
            ratesLayout: await getRatesPromise,
        };
    }
</script>


<script>
    import Rate from '../components/Rate.svelte';
    import { onMount } from 'svelte';
    import { fakeCursor } from '../stores';
    import { FAKE_CURSOR_BLINK_DELAY } from '../CONSTANTS.js';



    /*****************
     * Initial Props *
     *****************/
    export let bitcoin_rate;
    export let currencies;
    export let ratesLayout;
    export let isTutorial;


    /************
     * Tutorial *
     ************/
    if (isTutorial) enableTutorial();
    $: bodyHandler = isTutorial ? disableTutorial : null;
    $: demoHandler = isTutorial ? disableTutorial : enableTutorial;
    let intervalID;
    // Functions
    function enableTutorial() {
        intervalID = setInterval(()=>{ $fakeCursor = !$fakeCursor }, FAKE_CURSOR_BLINK_DELAY);
        isTutorial = true;
    }
    function disableTutorial() {
        clearInterval(intervalID);
        $fakeCursor = false;
        isTutorial = false;
    }




    /************
     * Handlers *
     ************/
    function AddRate() {
        ratesLayout = [...ratesLayout, null];
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
    {#each ratesLayout as rateLayout}
        {#if rateLayout}
            <Rate bind:rateLayout {currencies} />
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