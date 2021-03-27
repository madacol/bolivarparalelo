<script context="module">
    let Form;
    /*************
     * Constants *
     *************/
    // Animation delays
    const SETTINGS_DELAY = 300;
    const SETTINGS_BUTTON_DELAY = 150;
</script>

<script>
    import { slide } from 'svelte/transition';
    import HiddenInputDate from './HiddenInputDate.svelte';
    import RateData from './RateData.svelte';
    import Loader from './Loader.svelte';
    import getRateData from '../helpers/getRateData.js'
    import { _1D_in_ms } from '../CONSTANTS.js'
    import parseLocalDate from '../helpers/parseLocalDate.js'
    import { createEventDispatcher } from 'svelte';
    const dispatch = createEventDispatcher();
    /*********************************
     * Dynamic import on client-side *
     *********************************/
    import { onMount } from 'svelte';
    onMount(async () => {
        if (!Form) Form = (await import('./Form.svelte')).default;
    });


    export let rateLayout;
    export let currencies;


    let {params, config, data} = rateLayout;


    /****************
     * Opening Form *
     ****************/
    let showForm = false;
    let rateContainerRef;
    async function openSettings() {
        showForm = true;
        rateContainerRef.scrollIntoView({behavior: "smooth"})
    }
    if (!data) openSettings();


    /****************************
     * Handle changes to params *
     ****************************/
    // Setup, copying `params` into `newParams`
    let newParams = {...params};
    let isLoading;
    function hasParamsChanged(params, newParams) {
        if (params.counter_currency_code !== newParams.counter_currency_code) return true
        if (params.base_currency_code !== newParams.base_currency_code) return true
        if (params.isTimeRange !== newParams.isTimeRange) return true
        if (params.isTimeRange && newParams.isTimeRange) {
            if (params.start !== newParams.start) return true
            if (params.end !== newParams.end) return true
        }
        return false
    }
    async function paramsChangeHandler() {
        if (!newParams.counter_currency_code || !newParams.base_currency_code) return;

        // TODO: cancel any pending request
        const paramsChanged = hasParamsChanged(params, newParams)
        if (paramsChanged) {
            const {counter_currency_code, base_currency_code, isTimeRange, start, end} = newParams;
            isLoading = true;
            if (isTimeRange)
                data = await getRateData(counter_currency_code, base_currency_code, start, end);
            else
                data = await getRateData(counter_currency_code, base_currency_code);
            isLoading = false;
            params = {...newParams};
            rateLayout.params = params;
            dispatch('change');
        }
    }
    function searchDateHandler(e) {
        newParams.isTimeRange = true;
        newParams.start = parseLocalDate(e.target.value);
        newParams.end = newParams.start + _1D_in_ms;
        config.showType = 2;
        paramsChangeHandler()
    }


    /************
     * Handlers *
     ************/
    async function removeRate() {
        rateLayout = null;
        dispatch('change');
    }
</script>

<div bind:this={rateContainerRef} class="rateContainer" >
    {#if isLoading}
        <Loader/>
    {/if}
    <div class="rate">
        <div on:click={removeRate} class="left-buttons">
            <img src="/fa-icons/times.svg" alt="Borrar">
        </div>
        <div class="flex-grow">
            {#if data}
                <RateData {data} {currencies} {params} {config}/>
            {/if}
        </div>
        <div class="right-buttons">
            <HiddenInputDate on:change={searchDateHandler} >
                <img src="/fa-icons/search.svg" alt="Buscar Fecha">
            </HiddenInputDate>
        </div>
    </div>
    {#if !showForm}
        <div class="settingsButton borderRadiusBottom" on:click={openSettings}
        in:slide={{ delay: SETTINGS_DELAY, duration: SETTINGS_BUTTON_DELAY }}
        out:slide={{ duration: SETTINGS_BUTTON_DELAY }}
        >
            <img src="/fa-icons/cog.svg" alt="Opciones">
        </div>
    {:else}
        <div class="settingsButton" on:click={()=>showForm=false}
        in:slide={{ duration: SETTINGS_BUTTON_DELAY }}
        out:slide={{ delay: SETTINGS_DELAY, duration: SETTINGS_BUTTON_DELAY }}
        >
            <img src="/fa-icons/angle-up.svg" alt="Cerrar">
        </div>
        <div class="settings borderRadiusBottom"
        in:slide={{ delay: SETTINGS_BUTTON_DELAY, duration: SETTINGS_DELAY }}
        out:slide={{ duration: SETTINGS_DELAY }}
        >
            <svelte:component this={Form}
                {currencies}
                bind:newParams
                bind:config={config}
                on:change
                on:paramsChange={paramsChangeHandler}
            />
        </div>
    {/if}
</div>

<style>
    .rateContainer {
        text-align: center;
        width: 100%;
        max-width: 1100px;
        border: 1px solid var(--gray3);
        border-radius: 1em;
        margin-bottom: 1em;
        position: relative;
    }
    .rate {
        padding: 0.5em;
        display: flex;
        justify-content: center;
        align-items: center;
    }
    .left-buttons {
        margin-right: 0.7em;
    }
    .right-buttons {
        margin-left: 0.7em;
    }
    img {
        /* set color to white */
        filter: invert(100%) sepia(100%) saturate(0%) hue-rotate(241deg) brightness(103%) contrast(103%);
        height: 2em;
        padding: 0.3em;
        opacity: 50%;
        cursor: pointer;
        display: block;
    }
    img:hover,
    img:focus {
        opacity: 100%;
    }
    .settingsButton > img {
        font-size: 0.9em;
        display: inline-block;
    }
    .settingsButton {
        background-color: var(--gray3);
        cursor: pointer;
        line-height: 0;
    }
    .settingsButton:hover,
    .settingsButton:focus {
        background-color: var(--gray4);
        cursor: pointer;
    }
    .borderRadiusBottom {
        border-radius: 0 0 1em 1em;
    }
    .settings {
        background-color: var(--gray2)
    }
</style>