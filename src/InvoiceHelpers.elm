module InvoiceHelpers exposing (..)

import Types exposing (ContactDetails, InvoiceLines, Line, Product, Address, Currency(..))


currencySymb : Currency -> String
currencySymb currency =
    case currency of
        USD ->
            "$"

        GBP ->
            "£"

        EUR ->
            "€"


newEmptyLine : Line
newEmptyLine =
    Line (Product "" 0 21) 1 False


newContact : ContactDetails
newContact =
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
    if (cty < 0) then
        { line | quantity = 0 }
    else
        { line | quantity = cty }


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


total : InvoiceLines -> Float
total =
    List.map totalLine >> List.foldr (+) 0
