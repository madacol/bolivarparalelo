function getQueryUrl (counter_code, base_code, start_unix_time, end_unix_time) {
    let url = `/api/rate/${counter_code.toLowerCase()}/${base_code.toLowerCase()}`
    if (!start_unix_time)    return url

    url += `/time/${start_unix_time}`;
    if (!end_unix_time)    return url

    url += `/${end_unix_time}`;
    return url;
}

/**
 * Transforms miliseconds into a Human readable remaining time.
 * 
 * Output examples:
 * - Hace 38 segundos
 * - Hace 10 minutos
 * - Hace 1 hora, 10 minutos
 * - Hace 2 dias, 1 hora, 10 minutos
 * 
 * @param {Number} miliseconds 
 */
function getHumanTime(miliseconds) {
    const seconds = Math.floor(miliseconds / 1000);
    const minutesLeft = Math.floor(seconds / 60)
    if (minutesLeft == 0)
        return `${seconds} segundos`;

    const minutes = (minutesLeft % 60);
    const hoursLeft = ((minutesLeft-minutes) / 60);
    const hours = (hoursLeft % 24);
    const daysLeft = ((hoursLeft-hours) / 24);

    const time_strings = []
    if (daysLeft > 0) time_strings.push(`${daysLeft} dia${   (daysLeft > 1) ? 's' : ''}`);
    if (hours    > 0) time_strings.push(`${hours   } hora${  (hours    > 1) ? 's' : ''}`);
    if (minutes  > 0) time_strings.push(`${minutes } minuto${(minutes  > 1) ? 's' : ''}`);
    return time_strings.join(", ");
}

/**
 * Get latest rate or rates in a time range
 * 
 * When only `counter_code` and `base_code` are passed, this function will return the **latest rate**.
 * 
 * If `start_unix_time` and `end_unix_time` are passed too, this function returns a list of rates between the time range specified.
 * 
 * @param {String} counter_code - currency code, e.g. `ves`,`usd`, `btc`
 * @param {String} base_code - currency code, e.g. `ves`,`usd`, `btc`
 * @param {Number} start_unix_time - (Optional) initial unix time
 * @param {Number} end_unix_time - (Optional) final unix time
 */
async function getRateData (counter_code, base_code, start_unix_time=false, end_unix_time=false) {

    const fetch = this.fetch || fetch;

    const url = getQueryUrl(counter_code, base_code, start_unix_time, end_unix_time);
    const response = await fetch(url);
    const json = await response.json();

    /**
     * When requesting latest rate
     */
    if (!start_unix_time) {
        const {buy, sell, unix_time} = json;
        const updated_time = getHumanTime(Date.now() - unix_time);
        return {
            avg: (buy + sell)/2,
            buy,
            sell,
            updated_time,
        };
    }

    /**
     * When requesting rates in a time range
     */
    const rates = Object.values(json.rates)
    const updated_time = (rates.length === 1) && getHumanTime(Date.now() - rates[0].unix_time);
    const chart_data = [];
    // Calculate averages of each rate
    let sumAvg = 0;
    let sumBuy = 0;
    let sumSell = 0;
    rates.forEach( ({buy, sell, unix_time}) => {
        const avg = (buy + sell)/2;
        sumAvg += avg;
        sumBuy += buy;
        sumSell += sell;
        chart_data.push ({
            x: unix_time,
            y: avg.toFixed(2),
        });
    });
    return {
        avg: sumAvg / rates.length,
        buy: sumBuy / rates.length,
        sell: sumSell / rates.length,
        chart_data,
        updated_time,
    };
}

export default getRateData;