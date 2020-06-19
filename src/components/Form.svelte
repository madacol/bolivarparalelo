<script context="module">
	import { onMount } from 'svelte';
    import { _1H_in_ms, _1W_in_ms } from '../CONSTANTS.js'
    import parseLocalDate from '../helpers/parseLocalDate.js'

    /**
     * Check if browser supports input's type `datetime-local`
     * https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input/datetime-local#Examples
     */
    let browserSupportsDatetime;
    {
        const input = document.createElement('input');

        try {
            input.type = 'datetime-local';
        } catch (e) {
            console.log(e.description);
        }

        browserSupportsDatetime = (input.type === 'datetime-local')
    }

    const inputDateType = browserSupportsDatetime ? "datetime-local" : "date";


    /*************
     * Functions *
     *************/
    /**
     * Following functions have 2 versions,
     * one for input.type=='date' and another for input.type=='datetime-local',
     * depending if the browser supports 'datetime-local' or not
     *
     * `unixTime_to_inputValue` converts **unix time** into a value that can be understood by the correspondig input ('date' or 'datetime-local')
     * `inputValue_to_unixTime` Does the opposite, converts from the input's value to **unix time**
     */
    let unixTime_to_inputValue, inputValue_to_unixTime;
    {
        const stringOptions = [navigator.language, {minimumIntegerDigits: 2, useGrouping: false}];
        const date_to_input_date = date => {
            const year = date.getFullYear().toLocaleString(...stringOptions);
            const month = (date.getMonth()+1).toLocaleString(...stringOptions);
            const day = date.getDate().toLocaleString(...stringOptions);
            return `${year}-${month}-${day}`
        };

        if (!browserSupportsDatetime) {
            unixTime_to_inputValue = unixTime => {
                const date = new Date(unixTime);
                return date_to_input_date(date);
            }
            inputValue_to_unixTime = input_value => parseLocalDate(input_value);
        } else {
            unixTime_to_inputValue = unixTime => {
                const date = new Date(unixTime);
                const dateString = date_to_input_date(date)
                const hours = date.getHours().toLocaleString(...stringOptions)
                const minutes = date.getMinutes().toLocaleString(...stringOptions)
                return `${dateString}T${hours}:${minutes}`;
            }
            inputValue_to_unixTime = input_value => Date.parse(input_value);
        }
    }

    /*************
     * Constants *
     *************/
    const CHOOSE_TIME = [
        [false, "Más reciente"],
        [true, "Escoger fecha"],
    ]

</script>



<script>
    import CheckboxToggle from './CheckboxToggle.svelte'
    import RadioButton from './RadioButton.svelte'
    import { SHOW_CONFIG } from '../CONSTANTS.js'
    import { createEventDispatcher, tick } from 'svelte';
    const dispatch = createEventDispatcher();


    /*********
     * Props *
     *********/
    export let newParams;
    export let currencies;
    export let config;


    /**********
     * States *
     **********/
    let end_input_value, start_input_value;
    newParams.end = newParams.end || Date.now();
    newParams.start = newParams.start || newParams.end - _1W_in_ms;
    $: if (newParams.isTimeRange) {
        end_input_value = unixTime_to_inputValue(newParams.end);
        start_input_value = unixTime_to_inputValue(newParams.start);
    }

    function handleEndDate(e) { newParams.end = inputValue_to_unixTime(e.target.value) }
    function handleStartDate(e) { newParams.start = inputValue_to_unixTime(e.target.value) }
    async function dispatchParamsChanged() { setTimeout(() => dispatch('paramsChange'), 0) }

</script>

<div class="rateform">
    <div class="flags d-flex">
        <div class="d-flex flex-column">
            {#each currencies as currency}
                <label class="flag">
                    <input type="radio"
                        bind:group={newParams.base_currency_code}
                        value={currency.code}
                        on:change={dispatchParamsChanged}
                    >
                    <div>{currency.flag || currency.code.toUpperCase()}</div>
                </label>
            {/each}
        </div>
        <div class="d-flex flex-column">
            {#each currencies as currency}
                {#if currency.code !== "btc"}
                    <label class="flag">
                        <input type="radio"
                            bind:group={newParams.counter_currency_code}
                            value={currency.code}
                            on:change={dispatchParamsChanged}
                        >
                        <div>{currency.flag || currency.code.toUpperCase()}</div>
                    </label>
                {/if}
            {/each}
        </div>
    </div>
    <hr>
    <CheckboxToggle
        on:change
        label="Tasas de compra y venta:"
        bind:checked={config.showBuySell}
    />
    <hr>
    <div class="chooseTime">
        {#each CHOOSE_TIME as [value, label]}
            <RadioButton
                bind:group={newParams.isTimeRange}
                on:change={dispatchParamsChanged}
                {label}
                {value}
            />
        {/each}
    </div>
    {#if newParams.isTimeRange}
        <div class="timeRange">
            <label> Fecha Inicial:
                <input
                    type={inputDateType}
                    value={start_input_value}
                    on:change={handleStartDate}
                    on:change={dispatchParamsChanged}
                >
            </label>
            <label> Fecha Fin:
                <input
                    type={inputDateType}
                    value={end_input_value}
                    on:change={handleEndDate}
                    on:change={dispatchParamsChanged}
                >
            </label>
        </div>
        <hr>
        <div class="d-flex flex-column align-items-center">
            <span>Qué mostrar:</span>
            <br>
            <div class="d-flex justify-content-center">
                {#each SHOW_CONFIG as {name},i}
                    <RadioButton
                        on:change
                        label={name}
                        bind:group={config.showType}
                        value={i}
                    />
                {/each}
            </div>
        </div>
    {/if}
</div>

<style>
    .flags {
        justify-content: space-around;
        padding-top: 0.5em;
    }
    .flag {
        font-size: 35px;
        margin: 0;
        line-height: 0.9;
    }
    .flag > input {
        display: none
    }
    .flag > input:checked + div{
        font-size: 60px;
    }
    .flag > input:not(:checked) + div{
        cursor: pointer;
    }
    hr {
        border-color: var(--gray1)
    }
    .chooseTime {
        display: flex;
        justify-content: center;
    }
    .timeRange {
        margin-top: 0.7em;
    }
    .timeRange > label:first-child{
        margin-bottom: 0.5em
    }
</style>