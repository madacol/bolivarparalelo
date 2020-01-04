<script>
	import { onMount } from 'svelte';
	import Rate from './Rate.svelte';

	moment.locale(navigator.language)
	const _1Hms = 1000*3600;
	//const _24Hms = _1Hms*24;
	
	let rates;
	$: console.log(rates)

	const getRatesFromHash = () => {
		rates =	window.location.hash.slice(1).split(';').map( rate => {
					const [_counter_currency, _base_currency, range, _showRate, _showGraph] = rate.split(',')
					const _end_date_time = range && Date.now();
					const _date_time = range && (_end_date_time - Number(range)*_1Hms);
					return {_counter_currency, _base_currency, _date_time, _end_date_time, _showRate, _showGraph}
				})
	}

	window.location.hash = window.location.hash || `#ves,usd;ves,usd,${24*7},0;ves,eur`;
	getRatesFromHash();
	window.addEventListener('hashchange', getRatesFromHash);

	const ratesToHash = rates => rates.map( rate => {
		const {_counter_currency, _base_currency, _date_time, _end_date_time, _showRate, _showGraph} = rate;
		const rateHash = [];
		_counter_currency && rateHash.push(_counter_currency);
		_base_currency && rateHash.push(_base_currency);
		_date_time && _end_date_time && rateHash.push(Math.round(_date_time - _end_date_time)/_1Hms);
		_showRate && rateHash.push(_showRate);
		_showGraph && rateHash.push(_showGraph);
		//console.log(rateHash);
		return rateHash.join(',');
	})	
	const setRates = newRates => {
		rates = newRates;
		window.removeEventListener('hashchange', getRatesFromHash);
		window.location.hash = ratesToHash(rates);
		window.addEventListener('hashchange', getRatesFromHash);
	}

</script>

<div class="pos-f-t">
	<div class="collapse" id="navbarToggleExternalContent">
		<div class="content-nav-hide bg-gradient p-4">
			<h5 class="text-white h4">Más contenido</h5>
			<span class="text-muted">Próximamente...</span>
		</div>
	</div>
	<nav class="navbar navbar-expand-lg navbar-dark">
		<a href="/" class="navbar-brand">Bolívar Paralelo</a>
		<button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarSupportedContent" aria-controls="navbarToggleExternalContent" aria-expanded="false" aria-label="Toggle navigation">
		<span class="navbar-toggler-icon"></span>
		</button>
		<div class="justify-content-end collapse navbar-collapse" id="navbarSupportedContent">
		<ul class="navbar-nav">
			<!-- <li class="nav-item">
				<input type="date" id="get_date_history" on:change={handleSearchDate}>
				<label class="btn btn-outline-dark" for="get_date_history">
					<span id="calendar_text">{calendar_text} </span>
					<img alt="calendar icon" src="/icons/calendar_icon_white.png" width="25" height="25">
				</label>
			</li> -->
			<li class="nav-item px-2">
			</li>
		</ul>
	</nav>
</div>


<div id="body" class="px-2">
	{#each rates as rateOptions (JSON.stringify(rateOptions))}
		<Rate {...rateOptions} />
	{/each}
</div>

<nav class="navbar d-flex justify-content-between fixed-bottom">
	<div></div>
	<!-- <a class="navbar-brand">Bitcoin: {bitcoin_rate.rates.avg} $</a> -->
	<div>
		<a href="https://twitter.com/bolivarparalel0">
			<img alt="twitter icon" src="/icons/Twitter_Social_Icon_Circle_White.png" width="40" height="40">
		</a>
		<a href="https://github.com/madacol/bolivarparalelo">
			<img alt="github icon" src="/icons/GitHub-Mark-Light-64px.png" width="40" height="40">
		</a>
	</div>
</nav>

<style>
	nav{
		background-color: #003b68;
	}
	#body {
		display: flex;
		flex-direction: column;
		padding-bottom: 50px;
	}
	#navbarSupportedContent ul li {
		position: relative;
	}
</style>