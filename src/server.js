import express from 'express';
import compression from 'compression';
import morgan from 'morgan';
import cookieParser from 'cookie-parser';
import * as sapper from '@sapper/server';
import api from './api';

const app = express();
app.use(
	morgan('dev'),
	compression(),
	cookieParser(),
	express.static('static'),
);
app.use('/api', api)
app.use(sapper.middleware({
	session: (req, res) => ({
		layouts: {
			query: req.query.layout,
			cookie: req.cookies.layout,
		},
		langs: req.acceptsLanguages(),
	})
}))
app.listen(process.env.PORT, err => {
	if (err) console.log('error', err);
});

export default app;