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


    /************************
     * Latest bitcoin rates *
     ************************/
    async function getLatestBitcoinRates() {
        const response = await this.fetch('/api/latest_rates');
        const latest_bitcoin_rates = await response.json();
        const BITCOIN_RATE = {
            currency_id: 0,
            buy: 1,
            sell: 1
        }
        // This is needed to add bitcoin as an option in the `LatestRates` component
        latest_bitcoin_rates.push(BITCOIN_RATE)
        return latest_bitcoin_rates;
    }


    /*************************
     * Custom layout's rates *
     *************************/
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
        const getLatestBitcoinRatesPromise = getLatestBitcoinRates.call(this)
        const getCurrenciesPromise = getCurrencies.call(this)
        const getRatesPromise = getRates.call(this, layout)
        return {
            latest_bitcoin_rates: await getLatestBitcoinRatesPromise,
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
    import LatestRates from '../components/LatestRates.svelte';


    /*****************
     * Initial Props *
     *****************/
    export let latest_bitcoin_rates;
    export let currencies;
    export let ratesLayout;
    export let isTutorial;
    export let _lang;
    export let persistLayout;

    if (_lang) $lang = _lang;

    /****************
     * Latest rates *
     ****************/
    // Calculate `avg` and inject currencies
    latest_bitcoin_rates.forEach(rate => {
        rate.avg = (rate.buy + rate.sell) / 2
        rate.currency = currencies.find( ({id})=>id===rate.currency_id )
    });

    /************
     * Tutorial *
     ************/
    let intervalID;
    let timeoutID;
    if (isTutorial) enableTutorial();
    $: appHandler = isTutorial ? disableTutorial : null;
    // Functions
    function enableTutorial() {
        intervalID = setInterval(()=>{ $fakeCursor = !$fakeCursor }, FAKE_CURSOR_BLINK_DELAY);
        isTutorial = true;
        timeoutID = setTimeout(disableTutorial, 5000)
    }
    function disableTutorial() {
        clearInterval(intervalID);
        clearTimeout(timeoutID);
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
            Cookie.set('layout', layoutString, { expires: 365, sameSite: 'Strict' });
        }
        saveLayoutToUrl = async () => {
            const layoutString = encodeLayout(ratesLayout);
            const url = window.location.pathname + '?layout=' + layoutString;
            history.pushState(null, '', url);
        }
        if (persistLayout) saveLayoutToCookie();
    })
    $: ratesLayout = ratesLayout.filter(x=>x)   // remove `null` items


    /****************
     * Add new rate *
     ****************/
    const NEW_RATE_JSON = JSON.stringify({
        params: {isTimeRange: false},
        config: {showType: 0, showBuySell: true},
    })
    function AddRate() {
        ratesLayout = [...ratesLayout, JSON.parse(NEW_RATE_JSON)];
    }

    /**********************
     * Get specific rates *
     **********************/
    let usd_btc_avg_rate,
        ves_usd_avg_rate,
        ves_eur_avg_rate,
        ves_cop_avg_rate,
        ves_brl_avg_rate;
    {
        // Get currencies rates in bitcoin
        let usd_btc_rate,
            ves_btc_rate,
            eur_btc_rate,
            cop_btc_rate,
            brl_btc_rate;
        latest_bitcoin_rates.forEach( rate => {
            switch (rate.currency.code) {
                case "usd": usd_btc_rate = rate; break;
                case "ves": ves_btc_rate = rate; break;
                case "eur": eur_btc_rate = rate; break;
                case "cop": cop_btc_rate = rate; break;
                case "brl": brl_btc_rate = rate; break;
                default: break;
            }
        })
        usd_btc_avg_rate = getHumanRate(usd_btc_rate.avg)
        ves_usd_avg_rate = getHumanRate(ves_btc_rate.avg / usd_btc_rate.avg)
        ves_eur_avg_rate = getHumanRate(ves_btc_rate.avg / eur_btc_rate.avg)
        ves_cop_avg_rate = getHumanRate(ves_btc_rate.avg / cop_btc_rate.avg)
        ves_brl_avg_rate = getHumanRate(ves_btc_rate.avg / brl_btc_rate.avg)
    }


</script>


<svelte:head>
	<title>Bolivar Paralelo</title>
</svelte:head>

<main on:click={appHandler} on:keydown={appHandler}>
    <nav id="header">
        <a href="/">Bolívar Paralelo</a>
        <div class="menu">
            <a href="https://twitter.com/bolivarparalel0">
                <img alt="twitter icon" src="/icons/Twitter_Social_Icon_Circle_White.png" width="40" height="40">
            </a>
            <a href="https://github.com/madacol/bolivarparalelo">
                <img alt="github icon" src="/icons/GitHub-Mark-Light-64px.png" width="40" height="40">
            </a>
        </div>
    </nav>


    <div id="body">
        <LatestRates {latest_bitcoin_rates} />
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

    <nav id="footer">
        <div>
            <span title="VES / USD">{ves_usd_avg_rate}&nbsp;Bs <u>Dolar</u></span>
            <span title="VES / EUR">{ves_eur_avg_rate}&nbsp;Bs <u>Euro</u></span>
            <span title="USD / BTC">{usd_btc_avg_rate}&nbsp;$ <u>Bitcoin</u></span>
            <span title="VES / COP">{ves_cop_avg_rate}&nbsp;Bs <u>Peso</u></span>
            <span title="VES / BRL">{ves_brl_avg_rate}&nbsp;Bs <u>Real</u></span>
        </div>
    </nav>
</main>


<style>
    nav{
        display: flex;
        align-items: center;
        padding: .5rem 1rem;
        background-color: var(--navBackgroundColor);
        height: 60px;
        font-size: calc(13px + 0.3vw);
    }
    #header > a {
        text-decoration: none;
        font-size: 1.2em;
        cursor: pointer;
        white-space: nowrap;
        color: white;
    }
    #header .menu {
        display: flex;
        width: 100%;
        justify-content: flex-end;
    }
    #header .menu > a{
        margin-left: 10px;
    }
    #body {
        display: flex;
        flex-direction: column;
        align-items: center;
        height: calc(100vh - 120px);
        overflow: auto;
        line-height: 1.15;
        padding: 1em;
        font-size: calc(11px + 0.7vw);
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
    #footer {
        display: flex;
        justify-content: center;
        width: 100%;
        padding: 0;
    }
    #footer > div {
        display: flex;
        overflow: auto;
        justify-content: safe center;
        height: 100%;
        padding: 0.5em 0;
    }
    #footer > div > span {
        height: 100%;
        padding: 0 1em;
        width: min-content;
        height: min-content;
        text-align: center;
    }
</style>