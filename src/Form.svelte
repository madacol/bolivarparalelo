<script context="module">
	import { _1Hms } from './CONSTANTS.js'

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
	 * depending if the browser supports 'datetime-local'
	 * 
	 * `unixTime_to_input_value` converts **unix time** into a value that can be understood by the correspondig input ('date' or 'datetime-local')
	 * `input_value_to_unixTime` Does the opposite, converts from the input value to **unix time**
	 */
	let unixTime_to_input_value, input_value_to_unixTime;
	{
		const stringOptions = [navigator.language, {minimumIntegerDigits: 2, useGrouping: false}];
		const date_to_input_date = date => {
			const year = date.getFullYear().toLocaleString(...stringOptions);
			const month = (date.getMonth()+1).toLocaleString(...stringOptions);
			const day = date.getDate().toLocaleString(...stringOptions);
			return `${year}-${month}-${day}`
		};

		if (!browserSupportsDatetime) {
			unixTime_to_input_value = unixTime => {
				const date = new Date(unixTime);
				return date_to_input_date(date);
			}
			input_value_to_unixTime = input_value => Date.parse(input_value) + new Date().getTimezoneOffset() * _1Hms / 60;
		} else {
			unixTime_to_input_value = unixTime => {
				const date = new Date(unixTime);
				const dateString = date_to_input_date(date)
				const hours = date.getHours().toLocaleString(...stringOptions)
				const minutes = date.getMinutes().toLocaleString(...stringOptions)
				return `${dateString}T${hours}:${minutes}`;
			}
			input_value_to_unixTime = input_value => Date.parse(input_value);
		}
	}

</script>



<script>
	import CheckboxToggle from './CheckboxToggle.svelte'
	import RadioButton from './RadioButton.svelte'
	import { SHOW_CONFIG } from './CONSTANTS.js'


	/*********
	 * Props *
	 *********/
	export let counter_currency_code;
	export let base_currency_code;
	export let end_unix_time;
	export let start_unix_time;
	export let currencies;
	export let showBuySell=false;
	export let showConfig=0;
	export let isTimeRangeEnabled=false;


	/**********
	 * States *
	 **********/
	let end_input_value = isTimeRangeEnabled && unixTime_to_input_value(end_unix_time);
	let start_input_value = isTimeRangeEnabled && unixTime_to_input_value(start_unix_time);
	// Reactive assignments
	$: end_unix_time = isTimeRangeEnabled && input_value_to_unixTime(end_input_value);
	$: start_unix_time = isTimeRangeEnabled && input_value_to_unixTime(start_input_value);

</script>

<div class="rateform">
	<div class="flags d-flex">
		<div class="d-flex flex-column">
			{#each currencies as currency}
				<label class="flag">
					<input type="radio" bind:group={base_currency_code} value={currency.code}>
					<div>{currency.flag || currency.code.toUpperCase()}</div>
				</label>
			{/each}
		</div>
		<div class="d-flex flex-column">
			{#each currencies as currency}
				{#if currency.code !== "btc"}
					<label class="flag">
						<input type="radio" bind:group={counter_currency_code} value={currency.code}>
						<div>{currency.flag || currency.code.toUpperCase()}</div>
					</label>
				{/if}
			{/each}
		</div>
	</div>
	<hr>
	<CheckboxToggle
		label="Tasas de compra y venta:"
		bind:checked={showBuySell}
	/>
	<hr>
	<div class="timeRange">
		<span>Escojer rango de fechas</span>
		<br>
		<label>
			Fecha Inicial: <input type={inputDateType} value={start_input_value} on:change={e=>start_input_value=e.target.value}>
		</label>
		<label>
			Fecha Fin: <input type={inputDateType} value={end_input_value} on:change={e=>end_input_value=e.target.value}>
		</label>
	</div>
	<hr>
	<div class="d-flex flex-column align-items-center">
		<span>Qué mostrar:</span>
		<br>
		<div class="d-flex justify-content-center">
			{#each SHOW_CONFIG as {name},i}
				<RadioButton
					label={name}
					bind:group={showConfig}
					value={i}
				/>
			{/each}
		</div>
	</div>
</div>

<style>
	.flags {
		justify-content: space-around
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
	.timeRange span {
		display: flex;
		justify-content: center;
		font-size: 1.2em;
		margin-bottom: 0.7em;
	}
</style>