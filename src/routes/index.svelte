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
    import { _1H_in_ms } from '../CONSTANTS.js'
    import { decodeLayout } from '../helpers/layoutEncoding.js'
    import getHumanRate from '../helpers/getHumanRate.js';
    function getRates(layoutRaw) {
        const layout = decodeLayout(layoutRaw);
        return Promise.all(
            layout.map(
                async rateLayout => {
                    const {params: {counter_currency_code, base_currency_code, start, end}} = rateLayout;
                    const data = await getRateData.call(this, counter_currency_code, base_currency_code, start, end);
                    return {...rateLayout, data};
                }
            )
        )
    }

    /**
     * Preload props
     */
    export async function preload(page, {layouts, langs}) {
        const layout = layouts.query || layouts.cookie;
        const persistLayout = !layouts.query;
        const getBitcoinRatePromise = getBitcoinRate.call(this)
        const getCurrenciesPromise = getCurrencies.call(this)
        const getRatesPromise = getRates.call(this, layout)
        return {
            bitcoin_rate: await getBitcoinRatePromise,
            currencies: await getCurrenciesPromise,
            ratesLayout: await getRatesPromise,
            isTutorial: !layout,
            _lang: langs[0],
            persistLayout,
        };
    }
</script>


<script>
    import Rate from '../components/Rate.svelte';
    import { onMount } from 'svelte';
    import { fakeCursor, lang } from '../stores';
    import { FAKE_CURSOR_BLINK_DELAY } from '../CONSTANTS.js';
    import { encodeLayout } from '../helpers/layoutEncoding.js'



    /*****************
     * Initial Props *
     *****************/
    export let bitcoin_rate;
    export let currencies;
    export let ratesLayout;
    export let isTutorial;
    export let _lang;
    export let persistLayout;


    if (_lang) $lang = _lang;


    /************
     * Tutorial *
     ************/
    let intervalID;
    if (isTutorial) enableTutorial();
    $: bodyHandler = isTutorial ? disableTutorial : null;
    $: demoHandler = isTutorial ? disableTutorial : enableTutorial;
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


    /***************
     * Save Layout *
     ***************/
    let saveLayoutToCookie, saveLayoutToUrl;
    $: saveLayout = persistLayout ? saveLayoutToCookie : saveLayoutToUrl;
    onMount(async ()=>{
        const Cookie = (await import('js-cookie')).default;
        saveLayoutToCookie = async () => {
            const layoutString = encodeLayout(ratesLayout);
            Cookie.set('layout', layoutString, { expires: 365 });
        }
        saveLayoutToUrl = async () => {
            const layoutString = encodeLayout(ratesLayout);
            const url = window.location.pathname + '?layout=' + layoutString;
            history.pushState(null, '', url);
        }
        if (persistLayout) saveLayoutToCookie();
    })


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
            <Rate
                bind:rateLayout
                {currencies}
                on:change={saveLayout}
            />
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
        <div id="bitcoin" class="navbar-brand">Bitcoin: {getHumanRate(bitcoin_rate.avg)} $</div>
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
        font-size: calc(11px + 0.7vw);
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