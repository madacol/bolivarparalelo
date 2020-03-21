/**
 * Converts number to text and adds decimal and thousands separators
 * @param {Number} number 
 */
const getHumanRate = number => {
    if (number < 10000)
        return number.toLocaleString(navigator.language, {maximumSignificantDigits: 5})
    return number.toLocaleString(navigator.language, {maximumFractionDigits: 0});
}

export default getHumanRate;