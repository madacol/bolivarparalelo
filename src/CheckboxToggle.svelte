<script>
    export let checked;
</script>

<label class="switch">
    <input type="checkbox" bind:checked>
    <span class="slider"></span>
</label>

<style>
.switch {
    position: relative;
    display: inline-block;
    width: 2.4em;
    height: 1.3em;
}

/* Hide default HTML checkbox */
.switch input {
    opacity: 0;
    width: 0;
    height: 0;
}

/* The slider */
.slider {
    position: absolute;
    cursor: pointer;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background-color: var(--gray3);
    -webkit-transition: .4s;
    transition: .4s;
    border-radius: 1.3em;
}

.slider:before {
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

input:checked + .slider {
    background-color: var(--navBackgroundColor);
}

input:focus + .slider {
    box-shadow: 0 0 1px var(--navBackgroundColor);
}

input:checked + .slider:before {
    -webkit-transform: translateX(1em);
    -ms-transform: translateX(1em);
    transform: translateX(1em);
}
</style>