/**
 * Converts a date string to unix time at time 00:00 in the local timezone
 * This is just a wrapper around `Date.parse()` but adjusted to the local timezone
 * 
 * **Warning: DO NOT use this functions with strings that includes time**,
 * use `Date.parse()` instead, it already parses as the current timezone when time is included
 * 
 * @param {String} date_str - Date in string format that understands `Date.parse()`
 */
const parseLocalDate = (date_str) => Date.parse(date_str+"T00:00");

export default parseLocalDate