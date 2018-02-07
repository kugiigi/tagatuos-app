/*
  This library contains functions used within Tagatuos app.
  This includes functions that execute functions from ProcessFunc.js
  with some parameters predetermined using app specific variable such as
  setting values (i.e. current currency).


*/

.import "ProcessFunc.js" as Process

function formatMoney(value, noSymbol){
    var options = {
        symbol : noSymbol ? "" : tempSettings.currentCurrencySymbol,
        decimal : tempSettings.currentCurrencyDecimal,
        thousand: tempSettings.currentCurrencyThousand,
        precision : tempSettings.currentCurrencyPrecision,
        format: tempSettings.currentCurrencyFormat
    };
    return Process.formatMoney(value, tempSettings.currentCurrency,options)

}

