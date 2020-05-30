import express from 'express';
import compression from 'compression';
import * as sapper from '@sapper/server';

express() // You can also use Express
	.use(
		compression(),
		express.static('static'),
		sapper.middleware()
	)
	.listen(process.env.PORT, err => {
		if (err) console.log('error', err);
	});
