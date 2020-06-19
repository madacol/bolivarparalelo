<script>
    export let value;
    export let label;
    export let group;
</script>

<label>
    <input type="radio" on:change bind:group {value}>
    <span>{label}</span>
</label>

<style>
    input {
        display: none;
    }
    span {
        display: inline-block;
        cursor: pointer;
        padding: 0.3em 0.6em;
        margin: 0.4em;
        font-size: 1em;
        border-radius: 0.5em;
        border: 1px solid var(--gray3);
    }
    input:not(:checked) + span:hover {
        background-color: var(--gray3);
    }
    input:checked + span {
        background-color: var(--navBackgroundColor);
        border-color: var(--navBackgroundColor);
    }
</style>