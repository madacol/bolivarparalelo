<script lang="ts">
    export let checked: boolean;
    export let label: string;
</script>

<div>
    <label>
        {label}&nbsp;
        <input
            bind:checked
            on:change
            type="checkbox"
        >
        <div>
            <span/>
        </div>
    </label>
</div>

<style>

div {
    display: flex;
    justify-content: center;
}

label {
    cursor: pointer;
    display: flex;
    justify-content: center;
    align-items: center;
}

/* Hide default HTML checkbox */
input {
    position: absolute;
    opacity: 0;
    width: 0;
    height: 0;
}

label > div {
    display: inline-block;
    position: relative;
    width: 2.4em;
    height: 1.3em;
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

input:checked + div > span {
    background-color: var(--navBackgroundColor);
}

input:focus + div > span {
    box-shadow: 0 0 1px var(--navBackgroundColor);
}

input:checked + div > span:before {
    -webkit-transform: translateX(1em);
    -ms-transform: translateX(1em);
    transform: translateX(1em);
}
</style>