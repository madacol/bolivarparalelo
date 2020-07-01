<label>
    <input on:change type="date" {...$$restProps}>
    <div>
        <slot/>
    </div>
</label>

<style>
    label {
        display: block;
        position: relative;
    }
    input {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        opacity: 0;
        z-index: 1;
        cursor: pointer;
    }
    input::-webkit-calendar-picker-indicator {
        position: absolute;
        top: -150%;
        left: -150%;
        width: 300%;
        height: 300%;
        cursor: pointer;
    }
    input:hover + div > :global(*) {
        opacity: 100%;
    }
</style>