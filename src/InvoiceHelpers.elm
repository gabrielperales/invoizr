module InvoiceHelpers exposing (..)

import Invoice exposing (Invoice, InvoiceLines, Line, Product, Deduction, Currency(..))
import ContactDetails exposing (ContactDetails)
import Address exposing (Address)
import Helpers exposing (toFixed)
import I18n exposing (Language(..))
import Date


currencySymb : Currency -> String
currencySymb currency =
    case currency of
        USD ->
            "$"

        GBP ->
            "£"

        EUR ->
            "€"


stringToCurrency : String -> Result String Currency
stringToCurrency currency =
    case currency of
        "USD" ->
            Ok USD

        "GBP" ->
            Ok GBP

        "EUR" ->
            Ok EUR

        _ ->
            Err "bad currency"


stringToLanguage : String -> Result String Language
stringToLanguage language =
    case language of
        "EN" ->
            Ok EN

        "ES" ->
            Ok ES

        _ ->
            Err "bad language"


toCurrency : ( Currency, Float ) -> String
toCurrency ( currency, amount ) =
    case currency of
        EUR ->
            toFixed 2 amount ++ currencySymb currency

        _ ->
            currencySymb currency ++ toFixed 2 amount


newEmptyLine : Line
newEmptyLine =
    Line (Product "" 0 21) 1 False


newContact : ContactDetails
newContact =
    ContactDetails "" "" "" "" "" (Address "" "" "" "" "")


exampleContact : ContactDetails
exampleContact =
    ContactDetails
        "Sherlock & associates"
        ""
        "+34 600 123 123"
        "sherlock@holmes.co.uk"
        "astudyinpink.com"
        (Address "Baker St 221B" "London" "" "UK" "NW1 6XE")


addLine : Line -> InvoiceLines -> InvoiceLines
addLine =
    (::)


updateLineQuantity : Float -> Line -> Line
updateLineQuantity cty line =
    let
        quantity =
            if (cty < 0) then
                0
            else
                cty
    in
        { line | quantity = quantity }


addQuantity : Float -> Line -> Line
addQuantity qty line =
    updateLineQuantity ((+) line.quantity qty) line


removeQuantity : Float -> Line -> Line
removeQuantity qty line =
    updateLineQuantity ((-) line.quantity qty) line


addProduct : Line -> Line
addProduct =
    addQuantity 1


removeProduct : Line -> Line
removeProduct =
    removeQuantity 1


subtotalLine : Line -> Float
subtotalLine { product, quantity } =
    (*) product.price quantity


taxesLine : Line -> Float
taxesLine { product, quantity } =
    (*) ((*) product.price ((/) product.taxes 100)) quantity


totalLine : Line -> Float
totalLine line =
    (+) (subtotalLine line) (taxesLine line)


subtotal : InvoiceLines -> Float
subtotal =
    List.map subtotalLine >> List.foldr (+) 0


taxes : InvoiceLines -> Float
taxes =
    List.map taxesLine >> List.foldr (+) 0


deductions : Maybe Deduction -> InvoiceLines -> Float
deductions deduction invoicelines =
    (subtotal invoicelines) * ((Maybe.withDefault 0.0 deduction) / 100)


total : InvoiceLines -> Float
total =
    List.map totalLine >> List.foldr (+) 0


sortByDate : Invoice -> Invoice -> Order
sortByDate invoice1 invoice2 =
    case ( invoice1.date, invoice2.date ) of
        ( Just date1, Just date2 ) ->
            flip compare (Date.toTime date1) (Date.toTime date2)

        ( _, _ ) ->
            LT
