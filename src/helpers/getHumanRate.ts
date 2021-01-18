import { get } from 'svelte/store';
import { lang } from '../stores';

/**
 * Converts number to text and adds decimal and thousands separators
 * @param {Number} number
 */
const getHumanRate = (number: number) => {
    const options = (number < 10000)
        ? {maximumSignificantDigits: 4}
        : {maximumFractionDigits: 0};
    return number.toLocaleString( get(lang), options );
}

export default getHumanRate;