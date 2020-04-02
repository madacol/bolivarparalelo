<script>
	import CheckboxToggle from './CheckboxToggle.svelte'

	/*********
	 * Props *
	 *********/
	export let counter_currency_code;
	export let base_currency_code;
	export let end_unix_time;
	export let start_unix_time;
	export let currencies;
	export let showBuySell=false;

</script>

<div class="rateform">
	<div class="flags d-flex">
		<div class="d-flex flex-column">
			{#each currencies as currency}
				<label class="flag">
					<input type="radio" bind:group={base_currency_code} value={currency.code}>
					<div>{currency.flag || currency.code.toUpperCase()}</div>
				</label>
			{/each}
		</div>
		<div class="d-flex flex-column">
			{#each currencies as currency}
				{#if currency.code !== "btc"}
					<label class="flag">
						<input type="radio" bind:group={counter_currency_code} value={currency.code}>
						<div>{currency.flag || currency.code.toUpperCase()}</div>
					</label>
				{/if}
			{/each}
		</div>
	</div>
	<hr>
	<CheckboxToggle
		label="Tasas de compra y venta:"
		bind:checked={showBuySell}
	/>
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
	.flag > input {
		display: none
	}
	.flag > input:checked + div{
		font-size: 60px;
	}
	.flag > input:not(:checked) + div{
		cursor: pointer;
	}
	hr {
		border-color: var(--gray1)
	}
</style>