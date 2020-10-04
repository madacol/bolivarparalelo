import { get } from 'svelte/store';
import { lang } from '../stores';

/**
 * Converts number to text and adds decimal and thousands separators
 * @param {Number} number
 */
const getHumanRate = (number: number) => {
    if (number < 10000)
        return number.toLocaleString( get(lang), {maximumSignificantDigits: 4} );
    return number.toLocaleString( get(lang), {maximumFractionDigits: 0} );
}

export default getHumanRate;