<script>
	import Chart from './Chart.svelte';
	import Form from './Form.svelte';
	import Modal from './Modal.svelte';
	import RateCalculator from './RateCalculator.svelte';
	import getHumanRate from './helpers/getHumanRate.js'
	import { _1Hms } from './CONSTANTS.js'

	// Props
	export let rateHash;
	export let currencies;

	// Constants
	const SHOW_CONFIG = {
		0: {showGraph: false},
		1: {showGraph: true, showRateCalcWhenGraph: false}, // Default
		2: {showGraph: true, showRateCalcWhenGraph: true}
	}

	let [counter_currency_code, base_currency_code, showBuySell, start_hourRange_str, hourRange_str, showConfig] = rateHash.split(',');

	$: isRateValid = counter_currency_code && base_currency_code;
	const start_hourRange = start_hourRange_str && Number(start_hourRange_str);
	const hourRange = hourRange_str && Number(hourRange_str);
	const {showGraph, showRateCalcWhenGraph} = SHOW_CONFIG[showConfig] || SHOW_CONFIG[1]

	// Update `rateHash` whenever a parameter is changed
	$: {
		const rateList = []
		rateList.push(counter_currency_code);
		rateList.push(base_currency_code);
		rateList.push(showBuySell ? 1 : '');
		if (start_hourRange_str !== undefined || hourRange_str !== undefined) {
			rateList.push(start_hourRange_str);
			rateList.push(hourRange_str);
			if (showConfig) rateList.push(showConfig);
		}
		rateHash = rateList.join(',');
	}

	// States
	let end_date_time = hourRange && (Date.now() - start_hourRange*_1Hms);
	let date_time     = hourRange && (end_date_time - hourRange*_1Hms);
	let counter_currency = {};
	let base_currency = {};
	$: counter_currency = {...counter_currency, code: counter_currency_code };
	$: base_currency    = {...base_currency, code: base_currency_code };
	$: rate_Promise = fetchData(counter_currency_code, base_currency_code, date_time, end_date_time);
	let chartData = [];
	let updated_time = "";
	let showModal = false;


	/*************
	 * Functions *
	 *************/

	const getQueryUrl = (counter_code, base_code, date_time, end_date_time) => {
		let url = `/api/rate/${counter_code.toLowerCase()}/${base_code.toLowerCase()}`
		if (!date_time)    return url

		url += `/time/${date_time}`;
		if (!end_date_time)    return url

		url += `/${end_date_time}`;
		return url;
	}

	function getHumanTime(miliseconds) {
		const seconds = Math.floor(miliseconds / 1000);
		const minutesLeft = Math.floor(seconds / 60)
		if (minutesLeft == 0) {
			return `${seconds} segundos`;
		} else {
			const minutes = (minutesLeft % 60);
			const hoursLeft = ((minutesLeft-minutes) / 60);
			const hours = (hoursLeft % 24);
			const daysLeft = ((hoursLeft-hours) / 24);

			const time_strings = []
			if (daysLeft > 0) time_strings.push(`${daysLeft} dia${   (daysLeft > 1) ? 's' : ''}`);
			if (hours    > 0) time_strings.push(`${hours   } hora${  (hours    > 1) ? 's' : ''}`);
			if (minutes  > 0) time_strings.push(`${minutes } minuto${(minutes  > 1) ? 's' : ''}`);

			return time_strings.join(", ");
		}
	}

	const fetchData = async (counter_code, base_code, date_time, end_date_time) => {
		if (!counter_code || !base_code) {
			showModal = true;
			throw new Error('no currencies selected')
		}
		const url = getQueryUrl(counter_code, base_code, date_time, end_date_time);
		const response = await fetch(url);
		const json = await response.json();
		counter_currency = json.counter_currency;
		base_currency = json.base_currency;
		if (!date_time) {
			updated_time = getHumanTime(Date.now() - json.unix_time_ms)
			return {
				avg: parseFloat(json.avg),
				buy: parseFloat(json.buy),
				sell: parseFloat(json.sell)
			};
		}
		const rates = Object.values(json.rates)
		if (rates.length === 1) updated_time = getHumanTime(Date.now() - rates[0].unix_time_ms);
		const chart_data = [];
		let sumAvg = 0;
		let sumBuy = 0;
		let sumSell = 0;
		rates.forEach(rate => {
			const avg = parseFloat( rate.avg )
			sumAvg += avg;
			sumBuy += parseFloat( rate.buy );
			sumSell += parseFloat( rate.sell );
			const timestamp = rate.unix_time_ms;
			chart_data.push ({
				x: timestamp,
				y: avg.toFixed(2),
			});
		})
		chartData = chart_data;
		// search_text = e.target.value;
		return {
			avg: sumAvg / rates.length,
			buy: sumBuy / rates.length,
			sell: sumSell / rates.length
		};
	}


	/***********
	 * Handlers *
	 ***********/
	function removeRate () { rateHash = ''; }
	function closeModal () {
		if (!isRateValid)
			return removeRate();
		showModal=false;
	}

</script>

<div class={`rateContainer ${isRateValid ? '' : 'hide-collapse'}`}>
	<div class="d-flex justify-content-center align-items-center">
		<div class="mr-3">
			<i on:click={removeRate} class="fas fa-times"/>
		</div>
		<div class="flex-grow">
			{#await rate_Promise}
				<!-- promise is pending -->
				<p>Cargando...</p>
			{:then rate}
				<!-- promise was fulfilled -->
				{#if !showGraph || !date_time || chartData.length <= 1}
					<RateCalculator {rate} {base_currency} {counter_currency} {showBuySell} />
					<div class="update-time">Hace {updated_time}</div>
				{:else}
					{#if showRateCalcWhenGraph}
						<RateCalculator {rate} {base_currency} {counter_currency} />
					{/if}
					<div class="d-flex justify-content-between align-items-center mt-2" >
						<div class="flex-grow">
							<Chart {chartData}/>
						</div>
						<div class="d-flex justify-content-center align-items-center flex-column">
							<div class="chart-labels" style="margin-bottom: 1em">Promedio</div>
							<div class="chart-average"><strong>{getHumanRate(rate.avg)}</strong></div>
							<div>
								<div class="chart-labels">{@html counter_currency.namePlural.replace(' ','<br>')}</div>
								<div class="chart-labels" style="border-top: white 1px solid;">{@html base_currency.name.replace(' ','<br>')}</div>
							</div>
						</div>
					</div>
				{/if}
			{/await}
		</div>
		<div class="ml-3">
			<i class="fas fa-search"/>
			<br>
			<i on:click={()=>showModal=true} class="fas fa-cog mt-1"/>
		</div>
	</div>

	{#if showModal}
		<Modal on:close={closeModal}>
			<h3 slot="header">Configuracion</h3>
			<Form
				{currencies}
				bind:showBuySell
				bind:counter_currency_code
				bind:base_currency_code
				bind:end_date_time
				bind:date_time
			/>
		</Modal>
	{/if}
</div>

<style>
	.rateContainer {
		align-self: center;
		text-align: center;
		padding: 0.5em;
		width: 100%;
		max-width: 1100px;
		border: 1px solid var(--gray3);
		border-radius: 1em;
		margin-bottom: 1em;
	}
	.chart-average {
		font-size: 1em;
	}
	.fas {
		font-size: 1.2em;
		padding: 0.3em;
		opacity: 50%;
	}
	.fas:hover, .fas:focus {
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