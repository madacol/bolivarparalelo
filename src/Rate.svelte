<script>
	import Chart from './Chart.svelte';
	import Form from './Form.svelte';
	import Modal from './Modal.svelte';
	import RateCalculator from './RateCalculator.svelte';
	import getHumanRate from './helpers/getHumanRate.js'
	import { _1Hms, SHOW_CONFIG } from './CONSTANTS.js'


	/*********
	 * Props *
	 *********/
	export let rateHash;
	export let currencies;


	/**********
	 * States *
	 **********/
	let counter_currency = {};
	let base_currency = {};
	let chartData = [];
	let updated_time = "";
	let showModal = false;

	// Extract states from `rateHash`
	let counter_currency_code, base_currency_code, showBuySell, showConfig, isTimeRangeEnabled, end_unix_time, start_unix_time;
	{ // Set initial values of previous states
		const [configs, timeRangeConfigs] = rateHash.split('_');
		[counter_currency_code, base_currency_code, showBuySell] = configs.split(',');
		const [start_hourRange_str, hourRange_str, showConfig_str] = (timeRangeConfigs || '').split(',');
		isTimeRangeEnabled = (typeof timeRangeConfigs === "string") && timeRangeConfigs.length > 1;
		end_unix_time = start_hourRange_str && (Date.now() - Number(start_hourRange_str)*_1Hms);
		start_unix_time     = hourRange_str && (end_unix_time - Number(hourRange_str)*_1Hms);
		showConfig = Number(showConfig_str) || 0;
	}

    // Reactive Declarations
	$: counter_currency = {...counter_currency, code: counter_currency_code };
	$: base_currency    = {...base_currency, code: base_currency_code };
	$: rate_Promise = fetchData(counter_currency_code, base_currency_code, start_unix_time, end_unix_time);
	$: isRateValid = counter_currency_code && base_currency_code;
	$: ({showGraph, showRateCalcWhenGraph} = SHOW_CONFIG[showConfig] || SHOW_CONFIG[0])

	// Reactive Statements
	$: { // Update `rateHash` whenever a parameter is changed
		const allConfigs = [];
		{
			const configs = [counter_currency_code, base_currency_code];
			if (showBuySell) configs.push(1);
			allConfigs.push(configs.join(','));
		}
		if (isTimeRangeEnabled) {
			const start_hourRange = Math.round((Date.now() - end_unix_time) / _1Hms);
			const hourRange = Math.round((end_unix_time - start_unix_time) / _1Hms);
			const timeRangeConfigs = [start_hourRange, hourRange];
			if (showConfig > 0) timeRangeConfigs.push(showConfig);
			allConfigs.push(timeRangeConfigs.join(','));
		}
		rateHash = allConfigs.join('_');
	}


	/*************
	 * Functions *
	 *************/

	function getQueryUrl (counter_code, base_code, start_unix_time, end_unix_time) {
		let url = `/api/rate/${counter_code.toLowerCase()}/${base_code.toLowerCase()}`
		if (!start_unix_time)    return url

		url += `/time/${start_unix_time}`;
		if (!end_unix_time)    return url

		url += `/${end_unix_time}`;
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

	async function fetchData (counter_code, base_code, start_unix_time, end_unix_time) {
		if (!counter_code || !base_code) {
			showModal = true;
			throw new Error('no currencies selected')
		}
		const url = getQueryUrl(counter_code, base_code, start_unix_time, end_unix_time);
		const response = await fetch(url);
		const json = await response.json();
		counter_currency = json.counter_currency;
		base_currency = json.base_currency;
		if (!start_unix_time) {
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
	function removeRate () { rateHash = null; }
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
				{#if !showGraph || !isTimeRangeEnabled || chartData.length <= 1}
					<RateCalculator {rate} {base_currency} {counter_currency} {showBuySell} />
					<div class="update-time">Hace {updated_time}</div>
				{:else}
					{#if showRateCalcWhenGraph}
						<RateCalculator {rate} {base_currency} {counter_currency} {showBuySell} />
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
			<span slot="header">Configuracion</span>
			<Form
				{currencies}
				bind:showBuySell
				bind:showConfig
				bind:isTimeRangeEnabled
				bind:counter_currency_code
				bind:base_currency_code
				bind:end_unix_time
				bind:start_unix_time
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