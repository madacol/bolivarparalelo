import express from 'express';
import compression from 'compression';
import morgan from 'morgan';
import * as sapper from '@sapper/server';
import api from './api';

express() // You can also use Express
	.use(
		morgan('dev'),
		compression(),
		express.static('static'),
	)
	.use('/api', api)
	.use(sapper.middleware({
			session: (req, res) => ({
				// user: req.user,
				// lang: 'es'
			})
		}))
	.listen(process.env.PORT, err => {
		if (err) console.log('error', err);
	});