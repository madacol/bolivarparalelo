<script>

	// Props
	export let counter_currency_code;
	export let base_currency_code;
	export let end_date_time;
	export let date_time;

	$: end_date_ISO = (new Date(end_date_time)).toISOString();
	$: date_ISO = (new Date(date_time)).toISOString();
	$: end_date_human = (new Date(end_date_time)).toLocaleString();
	$: date_human = (new Date(date_time)).toLocaleString();

</script>

<div class="rateform">
	<input type="text" name="counter_currency_code" value={counter_currency_code}>
	<input type="text" name="base_currency_code" value={base_currency_code}>
	<label>
		<input type="range" name="end_date_time" bind:value={end_date_time} min={date_time} max={Date.now()}>
		<input type="datetime-local" bind:value={end_date_ISO} on:change={e=>alert(e.target.value)}>
		{end_date_human}
	</label>
	<label>
		<input type="range" name="date_time" bind:value={date_time} min={Date.now()-1000*3600*24*100} max={end_date_time}>
		<input type="datetime-local" bind:value={date_ISO} on:change={e=>alert(e.target.value)}>
		{date_human}
	</label>
</div>

<style>
</style>