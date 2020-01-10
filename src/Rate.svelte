<script>

	// Props
	export let _counter_currency_code;
	export let _base_currency_code;
	export let _date_time;
	export let _end_date_time;

	// States
	let counter_currency = { code: _counter_currency_code };
	let base_currency    = { code: _base_currency_code };
	let date_time     = _date_time;
	let end_date_time = _end_date_time;
	let history = [];
	$: fetching_data = fetchData(_counter_currency_code, _base_currency_code, date_time, end_date_time);
	let updated_time = "";

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

<rateContainer>
	{#await fetching_data}
		<!-- promise is pending -->
		<p>Cargando...</p>
	{:then rate}
		<!-- promise was fulfilled -->
		<div class="d-flex justify-content-between align-items-center">
			{#if !date_time || history.length <= 1}
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
						<canvas use:canvasMounted={history} height="150"></canvas>
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
				<i class="fas fa-cog mt-3"/>
			</div>
		</div>

	{/await}
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
	canvas {
		height: 150px;
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
	.content {
		flex-direction: column;
		/* min-height: 70vh; */
	}
</style>