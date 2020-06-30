import express from 'express';
import morgan from 'morgan';
import cookieParser from 'cookie-parser';
import * as sapper from '@sapper/server';
import api from './api';

const app = express();
if (process.env.NODE_ENV === 'development') {
	app.use('/flags', express.static('node_modules/flag-icon-css/flags/4x3'))
}
app.use(
	morgan('dev'),
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