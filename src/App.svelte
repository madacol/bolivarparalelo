<script>
	import Rate from './Rate.svelte';
	import Modal from './Modal.svelte';
	import Form from './Form.svelte';
	import { onMount } from 'svelte';


	/*************
	 * Constants *
	 *************/
	const defaultHashLayout = `#ves,usd;ves,eur;ves,usd,,0,${24*7}`
	const bitcoin_currency = {
		id: 0,
		code: "btc",
		symbol: "₿",
		name: "Bitcoin",
		namePlural: "Bitcoins",
	}


	/*********
	 * Setup *
	 *********/
	moment.locale(navigator.language)
	// Set hash to default if empty
	window.location.hash = window.location.hash || defaultHashLayout;
	let currencies = [];
	let bitcoin_rate;
	// Get rates from hash
	let rateHashes = window.location.hash.slice(1).split(';');
	// Filter removed rates and update hash
	$: { window.location.hash = rateHashes.filter(x=>x).join(';') }


	/**************
	 * LifeCycles *
	 **************/
	onMount(async () => {
		const response = await fetch('/api/currencies');
		currencies = [...(await response.json()), bitcoin_currency]
	})
	onMount(async () => {
		const response = await fetch('/api/rate/usd/btc');
		bitcoin_rate = await response.json();
	})

	/************
	 * HANLDERS *
	 ************/
	function AddRate(){
		rateHashes = [...rateHashes, ','];
	}

</script>

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


<div id="body">
	{#each rateHashes as rateHash}
		{#if rateHash}
			<Rate bind:rateHash {currencies} />
		{/if}
	{/each}
	<div id="newRate">
		<button on:click={AddRate}>
			Agregar Tasa
		</button>
	</div>
</div>

<nav class="navbar d-flex justify-content-between">
	<div></div>
	{#if bitcoin_rate}
		<div class="navbar-brand">Bitcoin: {bitcoin_rate.avg} $</div>
	{/if}
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
		background-color: var(--navBackgroundColor);
		min-height: 60px;
	}
	#body {
		display: flex;
		flex-direction: column;
		height: calc(100vh - 120px);
		overflow: auto;
		font-size: calc(10px + 0.9vw);
		line-height: 1.15;
		padding: 1em;
	}
	#navbarSupportedContent ul li {
		position: relative;
	}
	#newRate {
		align-self: center;
		width: 100%;
		max-width: 1100px;
	}
	#newRate > button {
		cursor: pointer;
		padding: 0.5em;
		width: 100%;
		max-width: 1100px;
		border: 1px dashed var(--gray3);
		border-radius: 1em;
		margin-bottom: 1em;
		min-height: 6em;
		background-color: transparent;
		color: white;
	}
	#newRate > button:focus {
		outline: 0;
		box-shadow: 0 0 0 .1em var(--gray3);
	}
	#newRate > button:hover {
		background-color: var(--gray1);
	}
</style>