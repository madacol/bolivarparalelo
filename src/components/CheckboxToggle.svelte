<script>
    export let checked;
    export let label;
</script>

<label>
    {label}
    <div>
        <input
            bind:checked
            on:change
            type="checkbox"
        >
        <span/>
    </div>
</label>

<style>
label {
    cursor: pointer;
}
div {
    position: relative;
    display: inline-block;
    width: 2.4em;
    height: 1.3em;
}

/* Hide default HTML checkbox */
input {
    opacity: 0;
    width: 0;
    height: 0;
}

/* The slider */
span {
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background-color: var(--gray3);
    -webkit-transition: .4s;
    transition: .4s;
    border-radius: 1.3em;
}

span:before {
    position: absolute;
    content: "";
    height: 1em;
    width: 1em;
    left: 0.15em;
    bottom: 0.15em;
    background-color: white;
    -webkit-transition: .4s;
    transition: .4s;
    border-radius: 50%;
}

input:checked + span {
    background-color: var(--navBackgroundColor);
}

input:focus + span {
    box-shadow: 0 0 1px var(--navBackgroundColor);
}

input:checked + span:before {
    -webkit-transform: translateX(1em);
    -ms-transform: translateX(1em);
    transform: translateX(1em);
}
</style>