<script context="module">
    /*************
     * Constants *
     *************/
    // Animation delays
    const SETTINGS_DELAY = 300;
    const SETTINGS_BUTTON_DELAY = 150;
</script>

<script>
    import { slide } from 'svelte/transition';
    import Chart from './Chart.svelte';
    import RateCalculator from './RateCalculator.svelte';
    import HiddenInputDate from './HiddenInputDate.svelte';
    import getHumanRate from '../helpers/getHumanRate.js'
    import { _1D_in_ms, SHOW_CONFIG } from '../CONSTANTS.js'
    import parseLocalDate from '../helpers/parseLocalDate.js'
    /*********************************
     * Dynamic import on client-side *
     *********************************/
    import { onMount } from 'svelte';
    let Form;
    onMount(async () => {
        Form = (await import('./Form.svelte')).default;
    });


    /*********
     * Props *
     *********/
    export let rateLayout;
    export let currencies;


    /**********
     * States *
     **********/
    let {params, showBuySell, showType, data} = rateLayout;
    rateLayout.newParams = params;
    $: ( {counter_currency_code, base_currency_code, timeRange} = params )
    $: counter_currency = currencies.find( ({code}) => (code === counter_currency_code) );
    $: base_currency = currencies.find( ({code}) => (code === base_currency_code) );
    $: ( {chartData, updated_time, ...rates} = data )
    $: ( {showGraph, showRateCalcWhenGraph} = SHOW_CONFIG[showType] )
    let showSettings = false;
    let rateContainerRef;

    /***********
     * Handlers *
     ***********/
    function removeRate () { rateLayout = null; }
    function searchDate (e) {
        const start = parseLocalDate(e.target.value),
        timeRange = {
            start,
            end: start + _1D_in_ms,
        }
        showType=2;
    }
    async function openSettings () {
        showSettings=true;
            setTimeout(
                ()=>rateContainerRef.scrollIntoView({behavior: "smooth"}),
                SETTINGS_DELAY+SETTINGS_BUTTON_DELAY
            )
    }

</script>

<div bind:this={rateContainerRef} class="rateContainer" >
    <div class="rate d-flex justify-content-center align-items-center">
        <div class="mr-3">
            <i on:click={removeRate} class="fas fa-times"/>
        </div>
        <div class="flex-grow">
            <!-- {#await rate_Promise}
                <p>Cargando...</p>
            {:then rate} -->
                <!-- promise was fulfilled -->
            {#if !showGraph || !timeRange || chartData.length <= 1 || showRateCalcWhenGraph}
                <RateCalculator {rates} {base_currency} {counter_currency} {showBuySell} />
                {#if updated_time}
                    <div class="update-time">Hace {updated_time}</div>
                {/if}
            {/if}
            {#if timeRange && showGraph && chartData.length > 1 }
                <div class="d-flex justify-content-between align-items-center mt-2" >
                    <div class="flex-grow">
                        <Chart {chartData}/>
                    </div>
                    <div class="d-flex justify-content-center align-items-center flex-column">
                        <div class="chart-labels" style="margin-bottom: 1em">Promedio</div>
                        <div class="chart-average"><strong>{getHumanRate(rates.avg)}</strong></div>
                        <div>
                            <div class="chart-labels">{@html counter_currency.namePlural.replace(' ','<br>')}</div>
                            <div class="chart-labels" style="border-top: white 1px solid;">{@html base_currency.name.replace(' ','<br>')}</div>
                        </div>
                    </div>
                </div>
            {/if}
            <!-- {/await} -->
        </div>
        <div class="ml-3">
            <HiddenInputDate on:change={searchDate} >
                <i class="fas fa-search"/>
            </HiddenInputDate>
        </div>
    </div>
    {#if !showSettings}
        <div class="settingsButton borderRadiusBottom" on:click={openSettings}
        in:slide={{ delay: SETTINGS_DELAY, duration: SETTINGS_BUTTON_DELAY }}
        out:slide={{ duration: SETTINGS_BUTTON_DELAY }}
        >
            <i class="fas fa-cog"/>
        </div>
    {:else}
        <div class="settingsButton" on:click={()=>showSettings=false}
        in:slide={{ duration: SETTINGS_BUTTON_DELAY }}
        out:slide={{ delay: SETTINGS_DELAY, duration: SETTINGS_BUTTON_DELAY }}
        >
            <i class="fas fa-angle-up"/>
        </div>
        <div class="settings borderRadiusBottom"
        in:slide={{ delay: SETTINGS_BUTTON_DELAY, duration: SETTINGS_DELAY }}
        out:slide={{ duration: SETTINGS_DELAY }}
        >
            <svelte:component this={Form}
                {currencies}
                bind:showBuySell
                bind:showType
                bind:timeRange
                bind:counter_currency_code
                bind:base_currency_code
            />
        </div>
    {/if}
</div>

<style>
    .rateContainer {
        align-self: center;
        text-align: center;
        width: 100%;
        max-width: 1100px;
        border: 1px solid var(--gray3);
        border-radius: 1em;
        margin-bottom: 1em;
    }
    .rate {
        padding: 0.5em;
    }
    .chart-average {
        font-size: 1em;
    }
    i {
        font-size: 1.2em;
        padding: 0.3em;
        opacity: 50%;
        cursor: pointer;
    }
    .settingsButton > i {
        font-size: 0.9em;
    }
    .settingsButton {
        background-color: var(--gray3);
        cursor: pointer;
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
    i:hover,
    i:focus {
        opacity: 100%;
    }
    .chart-labels {
        font-size: 0.8em;
    }
    .update-time {
        font-size: 0.7em;
        opacity: 50%;
    }
</style>