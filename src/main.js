var Elm = require('./App.elm');

var app = Elm.App.fullscreen({
  invoicer: localStorage.getItem('invoicer'),
  currency: localStorage.getItem('currency'),
  language: localStorage.getItem('language'),
  deduction: localStorage.getItem('deduction'),
});

app.ports.print.subscribe(function(){
  window.print();
});

app.ports.saveInvoicerDetails.subscribe(function(invoicer){
  localStorage.setItem('invoicer', invoicer);
});

app.ports.saveCurrency.subscribe(function(currency){
  localStorage.setItem('currency', currency);
});

app.ports.saveLanguage.subscribe(function(language){
  localStorage.setItem('language', language);
});

app.ports.saveDeduction.subscribe(function(deduction){
  if (deduction !== null) {
    localStorage.setItem('deduction', deduction);
  } else {
    localStorage.removeItem('deduction');
  }
});
