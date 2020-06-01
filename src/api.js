import Router from 'express-promise-router';
const router = new Router();
import db from './db';


router.get('/currencies', async (req, res) => {
    const { rows } = await db.query('SELECT * FROM currencies')
    res.send(rows)
})

async function getlastestRate(currency_code) {
    const { rows } = await db.query(
        'SELECT symbol, name, "namePlural", flag, code, buy, sell, lobit_prices.created_at AS date FROM lobit_prices\
            JOIN currencies ON lobit_prices.currency_id = currencies.id\
            WHERE code = $1\
            ORDER BY lobit_prices.created_at DESC\
            LIMIT 1',
        [currency_code]
    );
    if (!rows[0]) return null;
    const {buy, sell, date, ...currency} = rows[0];
    return {
        currency,
        buy,
        sell,
        date
    }
}

const BITCOIN = {
    code: 'btc',
    symbol: '₿',
    name: 'Bitcoin',
    namePlural: 'Bitcoins'
}
router.get('/rate/:counter_currency_code', async (req, res) => {
    const { counter_currency_code } = req.params;
    const counter = await getlastestRate(counter_currency_code);
    if (!counter) return res.status(404).send(`Currency ${counter_currency_code} not found`);
    const {currency, buy, sell, date} = counter;
    res.send({
        counter_currency: currency,
        base_currency: BITCOIN,
        buy,
        sell,
        date
    });
})

router.get('/rate/:counter_currency_code/:base_currency_code', async (req, res) => {
    const { counter_currency_code, base_currency_code } = req.params;
    const counterPromise = getlastestRate(counter_currency_code);
    const basePromise = getlastestRate(base_currency_code);
    const counter = await counterPromise;
    const base = await basePromise;
    console.log(counter, base)
    if (!counter) return res.status(404).send(`Currency ${counter_currency_code} not found`);
    if (!base)    return res.status(404).send(`Currency ${base_currency_code} not found`);
    res.send({
        counter_currency: counter.currency,
        base_currency: base.currency,
        buy: counter.buy / base.sell,
        sell: counter.sell / base.buy,
        date: counter.date
    });
})

export default router;