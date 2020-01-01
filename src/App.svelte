<script>
	import { onMount } from 'svelte';

	// STATES
	let top_rate = {
      numerator: "",
      denominator: "",
      rates: {
        avg: ""
      }
    };
	let bottom_rate = {
      numerator: "",
      denominator: "",
      rates: {
        avg: ""
      }
    };
	let bitcoin_rate = {
      rates: {
        avg: ""
      }
	};
	let chart_data = []
	let time = "";
	let calendar_text = 'Buscar fecha';


	let canvas;
	let chart;

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

	moment.locale(navigator.language)

	let handleSearchDate;
	onMount(async () => {

		// Getting and setting states
		const response = await fetch("/api");
		const json = await response.json();
		top_rate = json.rates.primary;
		bottom_rate = json.rates.secondary;
		bitcoin_rate = json.rates.bitcoin;
		chart_data = json.chart.data;
		time = json.time;

		const ctx = canvas.getContext('2d');
		const data = {
			datasets: [{
				borderColor: '#003b68',
				data: chart_data,
			}],
		}

		chart = new Chart(ctx, {
			// The type of chart we want to create
			type: 'line',

			// The data for our dataset
			data: data,

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

		handleSearchDate = async e => {
			const DAY_MS = 1000*3600*24
			const response = await fetch("/api/rate/ves/usd/time/"+String(e.target.valueAsNumber)+"/"+String(e.target.valueAsNumber+DAY_MS) );
			const json = await response.json();
			const rates = Object.values(json.rates)
			let sum = 0;
			const data = [];
			rates.forEach(rate => {
				const avg = parseFloat( rate.avg )
				const timestamp = rate.unix_time_ms
				sum += avg;
				data.push ({
					"x": timestamp,
					"y": avg.toFixed(2),
				});
			})
			const avg = sum / Object.values(rates).length;
			top_rate.rates.avg = getHumanRate(avg);
			chart.data.datasets[0].data = data;
			chart.resetZoom();
			calendar_text = e.target.value;
		}
	});
</script>

<div class="pos-f-t">
	<div class="collapse" id="navbarToggleExternalContent">
		<div class="content-nav-hide bg-gradient p-4">
			<h5 class="text-white h4">Más contenido</h5>
			<span class="text-muted">Próximamente...</span>
		</div>
	</div>
	<nav class="navbar navbar-expand-lg navbar-dark">
		<a class="navbar-brand">Bolívar Paralelo</a>
		<button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarSupportedContent" aria-controls="navbarToggleExternalContent" aria-expanded="false" aria-label="Toggle navigation">
		<span class="navbar-toggler-icon"></span>
		</button>
		<div class="justify-content-end collapse navbar-collapse" id="navbarSupportedContent">
		<ul class="navbar-nav">
			<li class="nav-item">
			<input type="date" id="get_date_history" on:change={handleSearchDate}>
			<label class="btn btn-outline-dark" for="get_date_history">
				<span id="calendar_text">{calendar_text} </span>
				<img alt="calendar icon" src="/icons/calendar_icon_white.png" width="25" height="25">
			</label>
			</li>
			<li class="nav-item px-2">
			</li>
		</ul>
	</nav>
</div>


<div id="body" class="px-2">

	<div class="d-flex justify-content-center update-time py-1">
		<div class="px-2">Actualizado hace {time}</div>
	</div>

	<div id="content" class="d-flex justify-content-center flex-wrap">

		<div class="d-flex justify-content-center flex-wrap flex-row">
			<div class="align-self-center"><div class="monto-label">        {top_rate.denominator}:</div></div>
			<div class="align-self-center"><div class="monto px-2 px-md-4" id="top-monto"> {top_rate.rates.avg}</div></div>
			<div class="align-self-center"><div class="monto-label">        {top_rate.numerator}</div></div>
		</div>

		<div class="chart-container" style="position: relative; width: 100%">
			<canvas bind:this={canvas} height="150"></canvas>
		</div>

		<div class="d-flex justify-content-center flex-wrap flex-row">
			<div class="align-self-center"><div class="monto-label">        {bottom_rate.denominator}:</div></div>
			<div class="align-self-center"><div class="monto px-2 px-md-4"> {bottom_rate.rates.avg}</div></div>
			<div class="align-self-center"><div class="monto-label">        {bottom_rate.numerator}</div></div>
		</div>

	</div>
</div>

<nav class="navbar d-flex justify-content-between fixed-bottom">
	<div></div>
	<a class="navbar-brand">Bitcoin: {bitcoin_rate.rates.avg} $</a>
	<div>
		<a href="https://twitter.com/bolivarparalel0">
			<img alt="twitter icon" src="/icons/Twitter_Social_Icon_Circle_White.png" width="40" height="40">
		</a>
		<a href="https://github.com/madacol/bolivarparalelo">
			<img alt="github icon" src="/icons/GitHub-Mark-Light-64px.png" width="40" height="40">
		</a>
	</div>
</nav>