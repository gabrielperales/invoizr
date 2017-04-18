require('expose-loader?PouchDB!pouchdb');

var Elm = require('./App.elm');
var db = new PouchDB('invoices');

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

app.ports.createInvoice.subscribe(function(invoice){
  db.post(invoice)
    .then(function(invoice){
      app.ports.invoice.send(invoice);
    })
});

app.ports.saveInvoice.subscribe(function(invoice){
  db.put(invoice)
    .then(function(invoice){
      app.ports.invoice.send(invoice);
    });
});

app.ports.getInvoices.subscribe(function(){
  db.allDocs()
    .then(function(invoices){
      app.ports.invoices.send(invoices);
    });
});

app.ports.getInvoice.subscribe(function(invoiceId){
  db.get(invoiceId)
    .then(function(invoice){
      app.ports.invoice.send(invoice);
    });
});

app.ports.deleteInvoice.subscribe(function(invoice){
  db.remove(invoice);
});