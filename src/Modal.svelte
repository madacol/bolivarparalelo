<script>
	import { createEventDispatcher, onDestroy } from 'svelte';

	const dispatch = createEventDispatcher();
	const close = () => dispatch('close');

	let modal;

	function handle_keydown (e) {
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
	<div class="body">
		<div>
			<slot></slot>
		</div>
	</div>

	<button class="closeButton" on:click={close}>Cerrar</button>
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
		display: flex;
		flex-direction: column;
		position: absolute;
		left: 50%;
		top: 50%;
		transform: translate(-50%,-50%);
		max-width: calc(100vw - 2em);
		max-height: calc(100vh - 120px);
		border-radius: 1em;
		background: var(--gray2);
		z-index: 2;
		padding: 1em;
		visibility: visible;
	}
	.body {
		overflow: auto;
		border-top: 1px solid var(--gray3);
		border-bottom: 1px solid var(--gray3);
		margin: 0.5em 0;
	}
	.body > div {
		margin: 0.3em 10px;
	}
	.header {
		font-size: 2em;
	}

	.closeButton {
		cursor: pointer;
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
		background-color: var(--gray3);
	}
</style>
