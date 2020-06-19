import { _1H_in_ms, _1W_in_ms } from "../CONSTANTS";

/**
 * Normalize functions to encode/decode base64
 * 
 * Browsers uses `atob`/`btoa` functions
 * But nodeJS uses `Buffer.from`
 */
const b64ToAscii = (typeof atob === 'function') ? atob : base64 => Buffer.from(base64, 'base64').toString('ascii');
const asciiToB64 = (typeof btoa === 'function') ? btoa : string => Buffer.from(string).toString('base64');

/**
 * Decodes a base64 string into a layout-config-object
 * @param {String} layoutString - A version+base64 string. E.g. `"1vdmVzLHVzZCwxO2NvcCxidGMsMTt1c2QsYnRjXzAsMTY4O3VzZCxidGNfMCwxNjgsMg=="`
 * 
 * @returns {Object} layout, E.g.
 * NOTE: if example string is decoded again, `start` and `end` won't match since they are encoded as the number of hours in the past relative to current time
 * ```js
 *   [
 *      {params: {counter_currency_code: "ves", base_currency_code: "usd", isTimeRange: false, start: undefined, end: undefined}, config: {showType: 0, showBuySell: true}},
 *      {params: {counter_currency_code: "cop", base_currency_code: "btc", isTimeRange: false, start: undefined, end: undefined}, config: {showType: 0, showBuySell: true}},
 *      {params: {counter_currency_code: "usd", base_currency_code: "btc", isTimeRange: true, start: 1591407769315, end: 1592012569315}, config: {showType: 0, showBuySell: false}},
 *      {
 *          params: {
 *              counter_currency_code: "usd",
 *              base_currency_code: "btc",
 *              isTimeRange: true,
 *              start: 1591407769315,
 *              end: 1592012569315
 *          },
 *          config: {
 *              showType: 2,
 *              showBuySell: false
 *          }
 *      }
 *   ]
 * ```
 */
export function decodeLayout(layoutString) {

    if (!layoutString) {
        // Set default layout
        const start = (Date.now()-_1W_in_ms);
        const end = Date.now();
        return [
            {params: {counter_currency_code: "ves", base_currency_code: "usd", isTimeRange: false}, config: {showType: 0, showBuySell: true}},
            {params: {counter_currency_code: "ves", base_currency_code: "eur", isTimeRange: false}, config: {showType: 0, showBuySell: false}},
            {params: {counter_currency_code: "ves", base_currency_code: "usd", isTimeRange: true, start, end}, config: {showType: 0, showBuySell: false}},
        ]
    }

    const [version, base64String] = layoutString.split(/v(.+)/);
    const layout = b64ToAscii(base64String).split(';').map( rateString => {
        const [configs, timeRangeConfigs] = rateString.split('_');
        const [counter_currency_code, base_currency_code, showBuySell] = configs.split(',');
        const isTimeRangeEnabled = (typeof timeRangeConfigs === "string") && timeRangeConfigs.length > 1;
        let isTimeRange = false, start, end, showType = 0;
        if (isTimeRangeEnabled) {
            const [start_hourRange_str, hourRange_str, showType_str] = (timeRangeConfigs || '').split(',');
            const start_hourRange = Number(start_hourRange_str);
            const hourRange = Number(hourRange_str);
            if (Number.isInteger(start_hourRange) && Number.isInteger(hourRange)) {
                // time range is valid
                isTimeRange = true;
                end = Date.now() - start_hourRange*_1H_in_ms;
                start = end - hourRange*_1H_in_ms;
                if (showType_str) showType = Number(showType_str);
            } else {
                console.error('time range is invalid');
                console.error('timeRangeConfigs:', timeRangeConfigs)
            }
        }
        const rate = {
            params: {
                counter_currency_code,
                base_currency_code,
                isTimeRange,
                end,
                start,
            },
            config: {
                showType,
                showBuySell: (showBuySell === '1'),
            }
        };

        return rate;
    })

    return layout;
}

/**
 * Encodes a layout-config-object into a base64 string.
 * See sibling function `decode()` for more information
 * @param {Object} layout 
 */
export function encodeLayout(layout) {

    const layoutStringList = layout.map(rate => {
        const { params: {counter_currency_code, base_currency_code, isTimeRange, start, end}, config: {showBuySell, showType} } = rate;

        const allConfigs = [];
        {
            const configs = [counter_currency_code, base_currency_code];
            if (showBuySell) configs.push('1');
            allConfigs.push(configs.join(','));
        }
        if (isTimeRange) {
            const start_hourRange = Math.round((Date.now() - end) / _1H_in_ms);
            const hourRange = Math.round((end - start) / _1H_in_ms);
            const timeRangeConfigs = [start_hourRange, hourRange];
            if (showType > 0) timeRangeConfigs.push(showType);
            allConfigs.push(timeRangeConfigs.join(','));
        }
        rateString = allConfigs.join('_');

        return rateString;
    })
    const layoutString = asciiToB64(layoutStringList.join(';'));

    return '1v'+layoutString;
}