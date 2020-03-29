<script>
	import { createEventDispatcher, onDestroy } from 'svelte';

	const dispatch = createEventDispatcher();
	const close = () => dispatch('close');

	let modal;

	const handle_keydown = e => {
		if (e.key === 'Escape') {
			close();
			return;
		}

		if (e.key === 'Tab') {
			// trap focus
			const nodes = modal.querySelectorAll('*');
			const tabbable = Array.from(nodes).filter(n => n.tabIndex >= 0);

			let index = tabbable.indexOf(document.activeElement);
			if (index === -1 && e.shiftKey) index = 0;

			index += tabbable.length + (e.shiftKey ? -1 : 1);
			index %= tabbable.length;

			tabbable[index].focus();
			e.preventDefault();
		}
	};

	const previously_focused = typeof document !== 'undefined' && document.activeElement;

	if (previously_focused) {
		onDestroy(() => {
			previously_focused.focus();
		});
	}
</script>

<svelte:window on:keydown={handle_keydown}/>

<div class="modal-background" on:click={close}></div>

<modal role="dialog" aria-modal="true" bind:this={modal}>
	<div class="header">
		<slot name="header"></slot>
	</div>
	<hr>
	<slot></slot>
	<hr>

	<div class="d-flex justify-content-center">
		<!-- svelte-ignore a11y-autofocus -->
		<button class="closeButton" autofocus on:click={close}>Cerrar</button>
	</div>
</modal>

<style>
	.modal-background {
		position: fixed;
		top: 0;
		left: 0;
		width: 100%;
		height: 100%;
		background: rgba(0,0,0,0.3);
		z-index: 1;
		visibility: visible;
	}

	modal {
		position: absolute;
		left: 50%;
		top: 50%;
		width: calc(100vw - 4em);
		max-width: 32em;
		max-height: calc(100vh - 4em);
		overflow: auto;
		transform: translate(-50%,-50%);
		padding: 1em;
		border-radius: 0.2em;
		background: rgb(36, 36, 36);
		z-index: 2;
		visibility: visible;
	}
	.header {
		font-size: 2em;
	}

	.closeButton {
		display: block;
		background-color: transparent;
		border: 1px solid var(--gray4);
		border-radius: 0.5em;
		padding: 1rem;
		color: white;
		width: 100%;
	}
	.closeButton:focus, .closeButton:hover {
		outline: 0;
		background-color: var(--gray4);
	}
</style>
