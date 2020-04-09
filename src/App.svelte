<script>
	import Rate from './Rate.svelte';
	import Modal from './Modal.svelte';
	import Form from './Form.svelte';
	import { onMount } from 'svelte';
	import { autoPilotBaseAmount, fakeCursor } from './stores.js';
	import { TUTORIAL_INTERVAL_DELAY, WRITE_DELAY, RANDOM_NUMBER_RANGE, FAKE_CURSOR_BLINK_DELAY } from './CONSTANTS.js'


	/*************
	 * Constants *
	 *************/
	const defaultHashLayout = `#ves,usd;ves,eur;ves,usd_0,${24*7}`
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
	// Check if hash is empty
	let isTutorial = false;
	if (!window.location.hash) {
		// Enable tutorial
		isTutorial = true;
		// Set hash to default
		window.location.hash = defaultHashLayout;
	}
	let currencies = [];
	let bitcoin_rate;
	// Get rates from hash
	let rateHashes = window.location.hash.slice(1).split(';');
	// Filter removed rates and update hash
	$: { window.location.hash = rateHashes.filter(x=>x).join(';') }

	/******************
	 * Setup Tutorial *
	 ******************/
	function getRandomInt(min, max) { // https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Math/random#Getting_a_random_integer_between_two_values
		min = Math.ceil(min);
		max = Math.floor(max);
		return Math.floor(Math.random() * (max - min)) + min; //The maximum is exclusive and the minimum is inclusive
	}
	/**
	 * Writes to the variable `$autoPilotBaseAmount` by appending the (list of)string received
	 * character-by-character with a delay between each write
	 * 
	 * @param {String|Array<String>} stringList - string or list of characters
	 * @param {Integer} delay - miliseconds to wait to add next character
	 */
	function delayedWrite (stringList, delay) {
		const setTimeoutID = setTimeout( () => {
			const [nextLetter, ...remainingLetters] = stringList;
			$autoPilotBaseAmount += nextLetter;
			if (remainingLetters.length > 0) {
				delayedWrite(remainingLetters, delay);
			} else {
				tutorialIntervals.pop();
			}
		}, delay)
		tutorialIntervals[2] = setTimeoutID;
	}
	function setRandomBaseNumber() {
		const randomNumber = getRandomInt(...RANDOM_NUMBER_RANGE);
		$autoPilotBaseAmount = '';
		const stringList = randomNumber.toString().split('');
		delayedWrite(stringList, WRITE_DELAY);
	}
	function enableTutorial() {
		tutorialIntervals[0] = setInterval(setRandomBaseNumber, TUTORIAL_INTERVAL_DELAY);
		tutorialIntervals[1] = setInterval(()=>{ $fakeCursor = !$fakeCursor }, FAKE_CURSOR_BLINK_DELAY);
	}
	function disableTutorial() {
		tutorialIntervals.forEach( intervalID => clearInterval(intervalID) );
		$fakeCursor = false;
		$autoPilotBaseAmount = 1;
	}
	let tutorialIntervals = [];
	$: if (isTutorial) enableTutorial()
	else disableTutorial()

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
	function AddRate() {
		rateHashes = [...rateHashes, ','];
	}

</script>

<nav class="navbar navbar-expand-lg navbar-dark">
	<a href="/" class="navbar-brand">Bolívar Paralelo</a>
	<button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarSupportedContent" aria-controls="navbarToggleExternalContent" aria-expanded="false" aria-label="Toggle navigation">
	<span class="navbar-toggler-icon"></span>
	</button>
	<div class="justify-content-end collapse navbar-collapse" id="navbarSupportedContent">
	<ul class="navbar-nav">
		<li class="nav-item">
			<span on:click={()=>isTutorial=true}>Ver demo</span>
		</li>
		<div class="border"></div>
		<li class="nav-item">
			<a href="/classic">Ver versión clásica</a>
		</li>
	</ul>
</nav>


<div id="body" on:click={()=>isTutorial=false}>
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
		<div id="bitcoin" class="navbar-brand">Bitcoin: {bitcoin_rate.avg} $</div>
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
		font-size: calc(13px + 0.3vw);
	}
	nav span,
	nav a {
		font-size: 1.2em;
		cursor: pointer;
		white-space: nowrap;
		color: white;
	}
	#body {
		display: flex;
		flex-direction: column;
		height: calc(100vh - 120px);
		overflow: auto;
		line-height: 1.15;
		padding: 1em;
		font-size: calc(10px + 0.9vw);
	}
	#bitcoin {
		font-size: 1.2em;
	}
	#navbarSupportedContent ul li {
		position: relative;
		margin: 0 1em;
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