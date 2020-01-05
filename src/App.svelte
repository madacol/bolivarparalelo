<script>
	import Rate from './Rate.svelte';

	moment.locale(navigator.language)
	const _1Hms = 1000*3600;
	//const _24Hms = _1Hms*24;
	
	let rates;

	const getRatesFromHash = () => {
		rates =	window.location.hash.slice(1).split(';').map( rate => {
					const [_counter_currency_code, _base_currency_code, range] = rate.split(',')
					const _end_date_time = range && Date.now();
					const _date_time = range && (_end_date_time - Number(range)*_1Hms);
					return {_counter_currency_code, _base_currency_code, _date_time, _end_date_time}
				})
	}

	window.location.hash = window.location.hash || `#ves,usd;ves,usd,${24*7};ves,eur`;
	getRatesFromHash();
	window.addEventListener('hashchange', getRatesFromHash);

	const ratesToHash = rates => rates.map( rate => {
		const {_counter_currency_code, _base_currency_code, _date_time, _end_date_time} = rate;
		const rateHash = [];
		_counter_currency_code && rateHash.push(_counter_currency_code);
		_base_currency_code && rateHash.push(_base_currency_code);
		_date_time && _end_date_time && rateHash.push(Math.round(_date_time - _end_date_time)/_1Hms);
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

<div>
	<div class="collapse" id="navbarToggleExternalContent">
		<div class="content-nav-hide bg-gradient p-4">
			<h5 class="text-white h4">Más contenido</h5>
			<span class="text-muted">Próximamente...</span>
		</div>
	</div>
	<nav class="navbar navbar-expand-lg navbar-dark">
		<a href="/beta" class="navbar-brand">Bolívar Paralelo (beta)</a>
		<button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarSupportedContent" aria-controls="navbarToggleExternalContent" aria-expanded="false" aria-label="Toggle navigation">
		<span class="navbar-toggler-icon"></span>
		</button>
		<div class="justify-content-end collapse navbar-collapse" id="navbarSupportedContent">
		<ul class="navbar-nav">
			<li class="nav-item">
				<a href="/" class="navbar-brand">Ir a clásico</a>
			</li>
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

<nav class="navbar d-flex justify-content-between">
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
		min-height: 60px;
	}
	#body {
		display: flex;
		flex-direction: column;
		padding-bottom: 50px;
		height: calc(100vh - 120px);
		overflow: auto;
	}
	#navbarSupportedContent ul li {
		position: relative;
	}
</style>