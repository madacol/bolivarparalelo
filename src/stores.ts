import { Writable, writable } from 'svelte/store';

export const fakeCursor: Writable<boolean> = writable(false);
export const lang: Writable<string> = writable('es-ve');
