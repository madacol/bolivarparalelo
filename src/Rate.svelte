<script>
	import Chart from './Chart.svelte';
	import Form from './Form.svelte';
	import Modal from './Modal.svelte';

	const _1Hms = 1000*3600;

	// Props
	export let rateHash;

	let [counter_currency_code, base_currency_code, start_hourRange_str, hourRange_str, _showGraph] = rateHash.split(',');
	const start_hourRange = start_hourRange_str && Number(start_hourRange_str);
	const hourRange = hourRange_str && Number(hourRange_str);
	const showGraph = (_showGraph !== "0")

	// States
	let end_date_time = hourRange && (Date.now() - start_hourRange*_1Hms);
	let date_time     = hourRange && (end_date_time - hourRange*_1Hms);
	let counter_currency = {};
	let base_currency = {};
	$: counter_currency = {...counter_currency, code: counter_currency_code };
	$: base_currency    = {...base_currency, code: base_currency_code };
	$: fetching_data = fetchData(counter_currency_code, base_currency_code, date_time, end_date_time);
	let chartData = [];
	let updated_time = "";
	let showModal = false;

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

	function getHumanRate(rate) {
		const num_digits = Math.log(Math.round(rate)) * Math.LOG10E + 1 | 0;  // https://stackoverflow.com/questions/14879691/get-number-of-digits-with-javascript
		let human_rate;
		if (num_digits < 4) {
			const temp_scaling_factor = 10**(4-num_digits)
			human_rate = Math.round( rate*temp_scaling_factor ) / temp_scaling_factor;
		} else {
			human_rate = Math.round(rate);
		}
		return human_rate.toLocaleString()
	}

	const fetchData = async (counter_code, base_code, date_time, end_date_time) => {
		const url = getQueryUrl(counter_code, base_code, date_time, end_date_time);
		const response = await fetch(url);
		const json = await response.json();
		counter_currency = json.counter_currency;
		base_currency = json.base_currency;
		if (!date_time) {
			updated_time = getHumanTime(Date.now() - json.unix_time_ms)
			return getHumanRate(parseFloat(json.avg));
		}
		const rates = Object.values(json.rates)
		let sum = 0;
		const chart_data = [];
		rates.forEach(rate => {
			const avg = parseFloat( rate.avg )
			const timestamp = rate.unix_time_ms
			sum += avg;
			chart_data.push ({
				"x": timestamp,
				"y": avg.toFixed(2),
			});
		})
		const avg = sum / rates.length;
		const rate = getHumanRate(avg);
		// const last_timestamp = rates[rates.length-1].unix_time_ms
		// search_text = e.target.value;
		chartData = chart_data;
		return rate
	}

	}

</script>

<rateContainer>
	{#await fetching_data}
		<!-- promise is pending -->
		<p>Cargando...</p>
	{:then rate}
		<!-- promise was fulfilled -->
		<div class="d-flex justify-content-between align-items-center">
			{#if !showGraph || !date_time || chartData.length <= 1}
				<div class="w-100">
					<div class="d-flex justify-content-center align-items-center flex-wrap">
						<div class="monto-label">
							1 {@html base_currency.name.replace(' ','<br>')}
						</div>
						<div class="monto-label ml-2">=</div>
						<div class="monto d-flex justify-content-center flex-wrap mx-2 px-md-4">
							{rate}
							<div class="align-self-center monto-label mx-2"> {@html counter_currency.namePlural.replace(' ','<br>')}</div>
						</div>
					</div>
					<div class="update-time">Hace {@html updated_time}</div>
				</div>
			{:else}
				<div class="d-flex justify-content-between align-items-center flex-grow" >
					<div class="flex-grow">
						<Chart {chartData}/>
					</div>
					<div class="d-flex justify-content-center align-items-center flex-column">
						<div class="chart-labels" style="margin-bottom: 1em">Promedio</div>
						<div class="chart-average"><strong>{rate}</strong></div>
						<div>
							<div class="chart-labels">{@html counter_currency.namePlural.replace(' ','<br>')}</div>
							<div class="chart-labels" style="border-top: white 1px solid;">{@html base_currency.name.replace(' ','<br>')}</div>
						</div>
					</div>
				</div>
			{/if}
			<div class="ml-3">
				<i class="fas fa-search"/>
				<br>
				<i on:click={()=>showModal=true} class="fas fa-cog mt-3"/>
			</div>
		</div>

	{/await}
	{#if showModal}
		<Modal on:close={()=>showModal=false}>
			<h1 slot="header">asdasdasd</h1>
			<Form bind:counter_currency_code bind:base_currency_code bind:end_date_time bind:date_time />
		</Modal>
	{/if}
</rateContainer>

<style>
	rateContainer {
		align-self: center;
		text-align: center;
		/* border-bottom: #ffffff1c 2px solid; */
		padding: 15px;
		width: 100vw;
		max-width: 1100px
	}
	.monto {
		font-size: calc(20px + 5vw);
		line-height: 1.15;
	}
	.monto-label {
		font-size: calc(10px + 1vw);
		line-height: 1.15;
	}
	.chart-average {
		font-size: calc(12px + 0.5vw);
	}
	.chart-labels {
		font-size: calc(7px + 0.3vw);
	}
	.update-time {
		font-size: calc(10px + 0.5vw);
		line-height: 1.15;
	}
</style>