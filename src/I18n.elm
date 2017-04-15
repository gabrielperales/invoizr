module I18n exposing (..)


type TranslationId
    = Invoice
    | BilledTo
    | Name
    | TaxId
    | Address
    | Street
    | City
    | ZipCode
    | InvoiceNumber
    | DateOfIssue
    | InvoiceTotal
    | ProjectBreakdown
    | ServiceName
    | Price
    | Taxes
    | Quantity
    | Amount
    | Save
    | Delete
    | Subtotal
    | Total
    | Print
    | English
    | Spanish
    | Deductions


type Language
    = EN
    | ES


translate : Language -> TranslationId -> String
translate language id =
    case language of
        EN ->
            case id of
                Invoice ->
                    "Invoice"

                BilledTo ->
                    "Billed to"

                Name ->
                    "Name"

                TaxId ->
                    "Tax id"

                Address ->
                    "Address"

                Street ->
                    "Street"

                City ->
                    "City"

                ZipCode ->
                    "Zip code"

                InvoiceNumber ->
                    "Invoice number"

                DateOfIssue ->
                    "Date of issue"

                InvoiceTotal ->
                    "Invoice total"

                ProjectBreakdown ->
                    "Project Breakdown"

                ServiceName ->
                    "Service name"

                Price ->
                    "Price"

                Taxes ->
                    "Taxes"

                Quantity ->
                    "Quantity"

                Amount ->
                    "Amount"

                Save ->
                    "Save"

                Delete ->
                    "Delete"

                Subtotal ->
                    "Subtotal"

                Total ->
                    "Total"

                Print ->
                    "Print"

                Spanish ->
                    "Spanish"

                English ->
                    "English"

                Deductions ->
                    "Deductions"

        ES ->
            case id of
                Invoice ->
                    "Factura"

                BilledTo ->
                    "Cliente"

                Name ->
                    "Nombre"

                TaxId ->
                    "C.I.F."

                Address ->
                    "Dirección"

                Street ->
                    "Calle"

                City ->
                    "Ciudad"

                ZipCode ->
                    "Código postal"

                InvoiceNumber ->
                    "Número de factura"

                DateOfIssue ->
                    "Fecha de emisión"

                InvoiceTotal ->
                    "Total a pagar"

                ProjectBreakdown ->
                    "Desglose"

                ServiceName ->
                    "Servicio"

                Price ->
                    "Precio"

                Taxes ->
                    "Impuestos"

                Quantity ->
                    "Unidades"

                Amount ->
                    "Cantidad"

                Save ->
                    "Actualizar"

                Delete ->
                    "Borrar"

                Subtotal ->
                    "Subtotal"

                Total ->
                    "Total"

                Print ->
                    "Imprimir"

                Spanish ->
                    "Español"

                English ->
                    "Inglés"

                Deductions ->
                    "Retenciones"
