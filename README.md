# BolivarParalelo

* https://bolivarparalelo.com
* https://twitter.com/bolivarparalel0

## Método para la obtencion del precio
Se obtiene el precio de compra y el precio de venta y se saca el promedio

Los precios de compra y venta se calculan analizando las ofertas disponibles en la pagina https://localbitcoins.com siguiendo estos pasos:

Supongamos que vamos a calcular el precio de compra de 1 bitcoin en bolivares:
* Se obtienen las primeras 3 paginas de ofertas en: https://localbitcoins.com/buy-bitcoins-online/ves/
* Se eliminan las ofertas de usuarios con menos de 100 transacciones, y con un feedback menor a 99
* Se filtran los siguientes metodos de pago:
```ruby
[
  "NATIONAL_BANK",
  "SPECIFIC_BANK",
  "CASH_DEPOSIT",
  "CASH_AT_ATM",
  "SEPA",
]
 ```
* Se normalizan los carácteres, se traducen frases y se extraen frases claves de la descripcion de cada oferta **(Opcional y especifico para cada moneda)**
* Se filtran aquellas ofertas cuya descripcion contenga alguna de las palabras claves **(Opcional y especifico para cada moneda)**
* Se ordenan de acuerdo al precio, para que la mejor tasa sea la primera
* Se itera de manera ordenada sobre cada oferta, y se devuelve el precio de aquella oferta que haya acumulado un volumen minimo de 0.5 bitcoins y que sea como mínimo la quinta oferta **(Para ser conservador con los precios)**

### Nota
Los parametros especificos de filtrado pueden cambiar sin previo aviso, para corroborar los parametros exactos pueden revisar en la seccion de **CONFIGURATIONS** en el archivo https://github.com/madacol/bolivarparalelo/blob/master/bin/getPrices.rb

## Advertencia
No uso el estándar financiero en el cuál EUR/USD significa cuántos dólares equivalen a 1 euro, uso un punto de vista matemático y el código está hecho con eso en mente, por lo tanto EUR/USD representa cuántos euros equivalen a 1 dólar.

# Api
* http://www.bolivarparalelo.com/api/rate/{counter_currency}/{base_currency}

Por ejemplo el precio del **dólar** en **bolívares**, sería **ves/usd**, oséa https://www.bolivarparalelo.com/api/rate/ves/usd
```json
{
  "counter_currency": "VES",
  "base_currency": "USD",
  "avg": "5782.688954173468910683633872456",
  "buy": "5774.320876448784292435066362588",
  "sell": "5791.027716925421468711305838651",
  "unix_time_ms": 1556306484000
}
```
