import Router from 'express-promise-router';
const router = new Router();
import db from './db';


router.get('/currencies', async (req, res) => {
    const { rows } = await db.query('SELECT * FROM currencies WHERE is_enabled = TRUE')
    res.send(rows)
})

router.get('/latest_rates', async (req, res) => {
    const { rows } = await db.query(
        `select
            currency_id,
            sell,
            buy,
            created_at
        from lobit_prices
        join (
            select
                currency_id,
                max(lobit_prices.id) as id
            from lobit_prices
            join currencies ON currency_id = currencies.id
            WHERE currencies.is_enabled = TRUE
            group by currency_id
        ) latest
        using (id, currency_id)`
    )

    const result = rows.map( ({currency_id, sell, buy, created_at}) => {
        return {
            currency_id,
            buy: Number(buy),
            sell: Number(sell),
            unix_time: created_at.getTime()
        }
    })

    res.send(result)
})
async function getlastestRate(currency_code) {
    const { rows } = await db.query(
        `SELECT symbol, name, "namePlural", flag, code, buy, sell, lobit_prices.created_at AS date FROM lobit_prices
            JOIN currencies ON lobit_prices.currency_id = currencies.id
            WHERE code = $1
            ORDER BY lobit_prices.created_at DESC
            LIMIT 1`,
        [currency_code]
    );
    if (rows.length === 0) return null;
    const {buy, sell, date, ...currency} = rows[0];
    return {
        currency,
        buy: Number(buy),
        sell: Number(sell),
        date
    }
}

const BITCOIN = {
    code: 'btc',
    symbol: '₿',
    name: 'Bitcoin',
    namePlural: 'Bitcoins'
}

router.get('/rate/:counter_currency_code/:base_currency_code?', async (req, res) => {
    const { counter_currency_code, base_currency_code } = req.params;
    const counterPromise = getlastestRate(counter_currency_code);
    const isBaseBitcoin = !base_currency_code || (base_currency_code === 'btc');
    let base;
    if (isBaseBitcoin)
        base = {currency: BITCOIN};
    else
        base = await getlastestRate(base_currency_code);
    const counter = await counterPromise;
    if (!counter) return res.status(404).send(`Currency "${counter_currency_code}" not found`);
    if (!base)    return res.status(404).send(`Currency "${base_currency_code}" not found`);
    res.send({
        counter_currency: counter.currency,
        base_currency: base.currency,
        buy: (isBaseBitcoin ? counter.buy : counter.buy / base.sell),
        sell: (isBaseBitcoin ? counter.sell : counter.sell / base.buy),
        unix_time: (isBaseBitcoin ? counter.date.getTime() : Math.min(counter.date.getTime(), base.date.getTime())),
    });
})


async function getTimeRangeRates(currency_code, start, end) {
    // Get currency data
    const { rows: currencies } = await db.query(
        'SELECT id, code, symbol, name, "namePlural", flag FROM currencies WHERE code = $1',
        [currency_code]
    );
    if (currencies.length === 0) return null;

    const [{id, ...currency}] = currencies;

    // Get rates
    const { rows: rates } = await db.query(
        `SELECT buy, sell, created_at AS date FROM lobit_prices
            WHERE currency_id = $1
                AND (created_at, created_at)
                    OVERLAPS ($2, $3)
            ORDER BY created_at DESC
            LIMIT 10000`,
        [id, start, end]
    );
    if (rates.length === 0) return null;
    return {rates, currency};
}

router.get('/rate/:counter_currency_code/:base_currency_code/time/:start_str/:end_str?', async (req, res) => {
    const { counter_currency_code, base_currency_code, start_str, end_str } = req.params;
    const start = new Date(Number(start_str) || start_str); // Try to cast to a number (unix time), if it fails fallback to string
    if (isNaN(start.getTime())) return res.status(404).send(`Time string "${start_str}" could not be parsed`);
    const end = new Date(
        (end_str &&
            ( Number(end_str) || end_str ) // Try to cast to a number (unix time), if it fails fallback to string
        ) || (start.getTime() + 60*60*1000) // If no `end_str`, set `end` to 1 hour after `start`
    );
    if (isNaN(end.getTime())) return res.status(404).send(`Time string "${end_str}" could not be parsed`);
    const counterPromise = getTimeRangeRates(counter_currency_code, start, end);
    let basePromise;
    if (base_currency_code !== 'btc') basePromise = getTimeRangeRates(base_currency_code, start, end);

    const counterCurrency = await counterPromise;
    if (!counterCurrency) return res.status(404).send(`Currency "${counter_currency_code}" not found`);
    const counter_rates_hourstamped = {};
    counterCurrency.rates.forEach( rate => {
        const hourstamp = `${rate.date.toLocaleDateString()} ${rate.date.getHours()}`
        counter_rates_hourstamped[hourstamp] = {
            buy: Number(rate.buy),
            sell: Number(rate.sell),
            unix_time: rate.date.getTime(),
        };
    })

    if ((base_currency_code === 'btc')) {
        return res.send({
            counter_currency: counterCurrency.currency,
            base_currency: BITCOIN,
            rates: counter_rates_hourstamped,
        })
    }

    const baseCurrency = await basePromise;
    if (!baseCurrency) return res.status(404).send(`Currency "${base_currency_code}" not found`);
    const rates_hourstamped = {};
    baseCurrency.rates.forEach( base_btc => {
        const hourstamp = `${base_btc.date.toLocaleDateString()} ${base_btc.date.getHours()}`
        const counter_btc = counter_rates_hourstamped[hourstamp];
        if (!counter_btc) return;
        rates_hourstamped[hourstamp] = {
            buy: counter_btc.buy / base_btc.sell,
            sell: counter_btc.sell / base_btc.buy,
            unix_time: counter_btc.unix_time,
        };
    })

    res.send({
        counter_currency: counterCurrency.currency,
        base_currency: baseCurrency.currency,
        rates: rates_hourstamped,
    })
})

export default router;