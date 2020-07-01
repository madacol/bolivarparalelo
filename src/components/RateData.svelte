<script>
    import Chart from './Chart.svelte';
    import RateCalculator from './RateCalculator.svelte';
    import getHumanRate from '../helpers/getHumanRate.js';
    import { SHOW_CONFIG } from '../CONSTANTS.js'

    export let data;
    export let currencies;
    export let params;
    export let config;

    $: ( {counter_currency_code, base_currency_code, isTimeRange} = params )
    $: counter_currency = currencies.find( ({code}) => (code === counter_currency_code) );
    $: base_currency = currencies.find( ({code}) => (code === base_currency_code) );
    $: ( {showBuySell, showType} = config )
    $: ( {showGraph, showRateCalcWhenGraph} = SHOW_CONFIG[showType] )
    $: ( {chartData, updated_time, ...rates} = data )
</script>

{#if !showGraph || !isTimeRange || chartData.length <= 1 || showRateCalcWhenGraph}
    <RateCalculator {rates} {base_currency} {counter_currency} {showBuySell}/>
    {#if updated_time}
        <div class="update-time">Hace {updated_time}</div>
    {/if}
{/if}
{#if isTimeRange && showGraph && chartData.length > 1 }
    <div class="chart" >
        <div class="flex-grow">
            <Chart {chartData}/>
        </div>
        <div class="average">
            <div class="label" style="margin-bottom: 1em">Promedio</div>
            <div class="number"><strong>{getHumanRate(rates.avg)}</strong></div>
            <div>
                <div class="label">{@html counter_currency.namePlural.replace(' ','<br>')}</div>
                <div class="label" style="border-top: white 1px solid;">{@html base_currency.name.replace(' ','<br>')}</div>
            </div>
        </div>
    </div>
{/if}

<style>
    .update-time {
        font-size: 0.7em;
        opacity: 50%;
    }
    .chart {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-top: 0.5em;
    }
    .average {
        display: flex;
        justify-content: center;
        align-items: center;
        flex-direction: column;
        margin-left: 0.5em;
    }
    .number {
        font-size: 1em;
    }
    .label {
        font-size: 0.8em;
    }
</style>