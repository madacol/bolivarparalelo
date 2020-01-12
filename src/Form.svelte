<script>

	// Props
	export let counter_currency_code;
	export let base_currency_code;
	export let end_date_time;
	export let date_time;
	export let currencies;

</script>

<div class="rateform">
	<div class="flags d-flex">
		<div class="d-flex flex-column">
			{#each currencies as currency}
				<label class="flag">
					{currency.flag}
					<input type="radio" bind:group={base_currency_code} value={currency.code}>
				</label>
			{/each}
		</div>
		<div class="d-flex flex-column">
			{#each currencies as currency}
				<label class="flag">
					{currency.flag}
					<input type="radio" bind:group={counter_currency_code} value={currency.code}>
				</label>
			{/each}
		</div>
	</div>
</div>

<style>
	.flags {
		justify-content: space-around
	}
	.flag {
		font-size: 35px;
		margin: 0;
		line-height: 0.9;
	}
</style>