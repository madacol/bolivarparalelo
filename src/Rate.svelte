<script>

	// Props
	export let _counter_currency;
	export let _base_currency;
	export let _date_time;
	export let _end_date_time;
	export let _showRate;
	export let _showGraph;

	// States
	let counter_currency     = _counter_currency;
	let base_currency   = _base_currency;
	let date_time     = _date_time;
	let end_date_time = _end_date_time;
	let showRate = _showRate;
	let showGraph = _showGraph;
	let history = [];
	$: fetching_data = fetchData(counter_currency, base_currency, date_time, end_date_time);
	let updated_time = "";

	const getQueryUrl = (counter_currency, base_currency, date_time, end_date_time) => {
		let url = `/api/rate/${counter_currency.toLowerCase()}/${base_currency.toLowerCase()}`
		if (!date_time)    return url

		url += `/time/${date_time}`;
		if (!end_date_time)    return url

		url += `/${end_date_time}`;
		return url;
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

	const fetchData = async (counter_currency, base_currency, date_time, end_date_time) => {
		const url = getQueryUrl(counter_currency, base_currency, date_time, end_date_time);
		const response = await fetch(url);
		const json = await response.json();
		const rates = Object.values(  (date_time) ? json.rates : [json]  )
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
		history = chart_data;
		return rate
	}

	const canvasMounted = (canvas, history) => {
		let ctx = canvas.getContext('2d');

		const height = canvas.height;

		let chart = new Chart(ctx, {
			// The type of chart we want to create
			type: 'line',

			// The data for our dataset
			data: {
				datasets: [{
					borderColor: '#003b68',
					data: history,
				}],
			},

			// Configuration options go here
			options: {
				legend: {display: false},
				maintainAspectRatio: false,
				tooltips: {
					mode: 'nearest',
					intersect: false
				},
				scales: {
					xAxes: [{
						type: 'time',
						time: {
							displayFormats: {
								hour: 'ddd hA',
							},
							tooltipFormat: 'MMM DD HH:mm',
						},
					}]
				},
				pan: {
					enabled: true,
					mode: 'x'
				},
				zoom: {
					enabled: true,
					mode: 'x',
				},
			}
		});

		// hack to keep height. For some reason after initialiazing chart, it forgets it.  --_(=/)_--
		canvas.height=height;
		canvas.style.height=`${height}px`;

		return {
			update(history) {
				chart.data.datasets[0].data = history;
				chart.resetZoom();
			}
		}

	}

</script>

<rateContainer class="container">
	{#await fetching_data}
		<!-- promise is pending -->
		<p>Cargando...</p>
	{:then rate}
		<!-- promise was fulfilled -->
		{#if updated_time}
			<div class="d-flex justify-content-center update-time py-1">
				<div class="px-2">Actualizado hace {updated_time}</div>
			</div>
		{/if}

		<div class="content d-flex justify-content-center flex-wrap">

			{#if showRate !== "0"}
				<div class="d-flex justify-content-center flex-wrap flex-row">
					<div class="align-self-center"><div class="monto-label">        {base_currency}:</div></div>
					<div class="align-self-center"><div class="monto px-2 px-md-4" id="top-monto"> {rate}</div></div>
					<div class="align-self-center"><div class="monto-label">        {counter_currency}</div></div>
				</div>
			{/if}
			{#if showGraph !== "0" && history.length > 2}
				<div class="chart-container" style="position: relative; width: 100%">
					<canvas use:canvasMounted={history} height="150"></canvas>
				</div>
			{/if}
		</div>
	{/await}
</rateContainer>

<style>
	rateContainer {
		align-self: center;
		text-align: center;
		border-bottom: #ffffff1c 2px solid;
		padding: 10px;
	}
	canvas {
		height: 150px;
	}
	.monto {
		font-size: calc(30px + 6vw);
		line-height: 1.15;
	}
	.monto-label {
		font-size: calc(10px + 2vw);
		line-height: 1.15;
	}
	.update-time {
		font-size: calc(10px + 1vw);
		line-height: 1.15;
	}
	.btn-outline-dark {
		border-color: white;
		color: white;
	}
	#get_date_history {
		position: absolute;
		width: 100%;
		height: 100%;
		opacity: 0;
	}
	#get_date_history::-webkit-calendar-picker-indicator {
		position: absolute;
		width: 100%;
		height: 100%;
	}
	#get_date_history:hover + label {
		background-color: black;
	}
	label {
		margin: 0;
	}
	.content {
		flex-direction: column;
		/* min-height: 70vh; */
	}
</style>