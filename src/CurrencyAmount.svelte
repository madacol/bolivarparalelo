<script>
    import getHumanRate from './helpers/getHumanRate.js'
    import normalizeNumberSeparators from './helpers/normalizeNumberSeparators.js'

    // Props
    export let handleAmountChange;
    export let amount;
    export let currency;

    $: text = getHumanRate(amount)

    // $: attr_name = (amount === 1) ? "name" : "namePlural"

    //Handlers
    const handleInputWidth = e => e.target.size = (e.target.value.length || 1)

    const handleChange = e => {
        const numberString = normalizeNumberSeparators(e.target.value);
        const parsedNumber = parseFloat(numberString);
        let newAmount;
        if (parsedNumber) {
            newAmount = parsedNumber;
            e.target.value = numberString;
        } else {
            newAmount = 1;
            e.target.value = 1;
        }
        handleAmountChange(newAmount);
    }

</script>


<div class="d-flex align-items-center flex-wrap">
    <input type="text" on:keyup={handleInputWidth} on:change={handleChange} value={text} size={text.length} />
    <span>{@html currency.code.toUpperCase()}</span>
</div>


<style>
    div > input {
        font-size: calc(10px + 3vw);
        line-height: 1.15;
        background-color: transparent;
        color: white;
        border: 0;
        border-bottom: 1px solid;
    }
    div > span {
        margin-left: 0.3em;
    }
</style>