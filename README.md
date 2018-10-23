# BolivarParalelo

* https://bolivartoday.herokuapp.com/
* http://bolivarparalelo.com **(sin HTTPS por ahora)**

## Método para la obtencion del precio
El precio se calcula analizando las ofertas disponibles en la pagina https://localbitcoins.com siguiendo estos pasos:

Supongamos que vamos a calcular el precio de compra de 1 bitcoin con bolivares:
* Se obtienen las primeras 3 paginas de ofertas en: https://localbitcoins.com/buy-bitcoins-online/ves/
* Se eliminan las ofertas de usuarios con menos de 100 transacciones, y con un feedback menor a 99
* Se filtran los siguientes metodos de pago:
```
[
  "NATIONAL_BANK",
  "SPECIFIC_BANK",
  "CASH_DEPOSIT",
  "CASH_AT_ATM",
  "SEPA",
]
 ```
* Se normalizan los carácteres, se traducen frases y palabras claves **(Opcional y especifico para cada moneda)**
* Se filtran de acuerdo a las palabras claves **(Opcional y especifico para cada moneda)**
* Se ordenan de acuerdo al precio, para que la mejor tasa sea la primera
* Se itera sobre cada oferta, y se devuelve aquella oferta que haya acumulado un volumen minimo de 0.5 bitcoins y que sea la quinta oferta o mayor **(Para ser conservador con los precios)**

### Nota
Los parametros especificos pueden cambiar sin previo aviso, para corroborar pueden revisar en la seccion de **CONFIGURATIONS** en el archivo https://github.com/madacol/bolivarparalelo/blob/master/bin/getPrices.rb
