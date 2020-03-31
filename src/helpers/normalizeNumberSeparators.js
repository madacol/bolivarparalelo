const decimalSeparator = (1.1).toLocaleString().substring(1, 2);    // Extract the decimal separator character
const thousandSeparator = (10000).toLocaleString().substring(2, 3); // Extract the thousand separator character
/**
 * Removes thousand separators and normalizes decimal separator to `.`
 * @param {String} numberText 
 */
const normalizeNumberSeparators = numberText => (
    numberText.split(thousandSeparator).join('')
              .split(decimalSeparator).join('.')
);

export default normalizeNumberSeparators;
