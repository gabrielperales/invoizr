module Views exposing (..)

import Html exposing (..)
import Html.Attributes exposing (type_, checked, name, placeholder, value, action, id, class, style)
import Html.Events exposing (onSubmit, onInput, onClick, onDoubleClick)
import Types exposing (ContactDetails, InvoiceLines, Line, Deduction, Msg(..), Currency(..), Model)
import InvoiceHelpers exposing (currencySymb, toCurrency, subtotalLine, subtotal, taxes, deductions, total)
import DatePicker
import I18n exposing (translate, TranslationId(..), Language(..))


toolbar : Model -> Html Msg
toolbar model =
    let
        { language, invoice, invoices } =
            model

        options =
            invoices
                |> List.map (\invoice -> option [] [ text <| Maybe.withDefault "Not valid date" <| Maybe.map toString invoice.date ])
                |> (::) (option [] [ text "..." ])

        isChecked =
            case invoice.deduction of
                Just _ ->
                    True

                _ ->
                    False
    in
        div [ class "no-print m-tb-1em" ]
            [ button [ onClick <| SetLanguage EN ] [ text <| translate language English ]
            , text "|"
            , button [ onClick <| SetLanguage ES ] [ text <| translate language Spanish ]
            , text "|"
            , button [ onClick <| SetCurrency EUR ] [ text "€" ]
            , text "|"
            , button [ onClick <| SetCurrency GBP ] [ text "£" ]
            , text "|"
            , button [ onClick <| SetCurrency USD ] [ text "$" ]
            , text "|"
            , button [ onClick <| SavePort invoice ] [ text <| translate language Save ]
            , text "|"
            , label [ class "p" ]
                [ text <| translate language Load
                , select [ class "d-inline-block" ] options
                ]
            , text "|"
            , button [ onClick PrintPort ] [ text <| translate language Print ]
            , text "|"
            , label [ class "p" ]
                [ text <| translate language Deductions
                , input [ type_ "checkbox", checked isChecked, onClick ToggleDeductions ] []
                ]
            ]


invoiceHeader : Language -> ContactDetails -> Html Msg
invoiceHeader language invoicer =
    let
        { name, taxes_id, phone, email, website, address } =
            invoicer

        inputText classes val change =
            input [ class ("d-block col-12 bc-transparent b-none c-white p " ++ classes), type_ "text", value val, onInput change ] []

        inputDefault =
            inputText "m-1em"

        inputBigger =
            inputText "h4 m-0 m-tb-0-75em p-0 ta-left"
    in
        header [ class "row header p-tb-1-5em p-lr-3em" ]
            [ div [ class "col-4" ]
                [ inputBigger name <| \value -> UpdateInvoicer { invoicer | name = value }
                , h1 [] [ text <| translate language Invoice ]
                ]
            , div [ class "col-sm-6 col-4 ta-right" ]
                [ inputDefault phone <| \value -> UpdateInvoicer { invoicer | phone = value }
                , inputDefault email <| \value -> UpdateInvoicer { invoicer | email = value }
                , inputDefault website <| \value -> UpdateInvoicer { invoicer | website = value }
                ]
            , div [ class "col-sm-6 col-4 ta-right" ]
                [ inputDefault address.street <| \value -> UpdateInvoicer { invoicer | address = { address | street = value } }
                , inputDefault address.city <| \value -> UpdateInvoicer { invoicer | address = { address | city = value } }
                , inputDefault address.zip <| \value -> UpdateInvoicer { invoicer | address = { address | zip = value } }
                ]
            ]


contactInfoView : Language -> ContactDetails -> Html Msg
contactInfoView language { name, taxes_id, address } =
    let
        inputText pholder val =
            input [ class "b-none m-b-0-5em", type_ "text", placeholder pholder, value val ] []
    in
        div []
            [ p [ class "m-b-0-5em" ]
                [ text <| (translate language Name) ++ " :"
                , inputText (translate language Name) name
                ]
            , p [ class "m-b-0-5em" ]
                [ text <| (translate language TaxId) ++ ": "
                , inputText (translate language TaxId) taxes_id
                ]
            , p [ class "m-b-0-5em" ] [ text <| (translate language Address) ++ ": " ]
            , div [ class "p-lr-1em" ]
                ([ ( address.street, Street ), ( address.city, City ), ( address.zip, ZipCode ) ]
                    |> List.map (\( value, translateId ) -> inputText (translate language translateId) value)
                    |> List.intersperse (br [] [])
                )
            ]


lineView : ( Int, Line ) -> Html Msg
lineView ( index, line ) =
    let
        { product, quantity } =
            line

        { name, price, taxes } =
            product
    in
        tr [ class "row col-12", onDoubleClick <| ToggleEditLine index ]
            [ td [ class "col-3 p-0 ta-right" ] [ text name ]
            , td [ class "col-3 p-0 ta-right" ] [ text <| toString price ]
            , td [ class "col-2 p-0 ta-right" ] [ text <| (toString taxes) ++ " %" ]
            , td [ class "col-2 p-0 ta-right" ] [ text <| toString quantity ]
            , td [ class "col-2 p-0 ta-right" ] [ text <| toString <| subtotalLine line ]
            ]


editLineView : Language -> ( Int, Line ) -> Html Msg
editLineView language ( index, line ) =
    let
        { product, quantity } =
            line

        { name, price, taxes } =
            product

        updateField field value =
            let
                floatValue =
                    Result.withDefault 0 <| String.toFloat value
            in
                case field of
                    "name" ->
                        UpdateLine index { line | product = { product | name = value } }

                    "price" ->
                        UpdateLine index { line | product = { product | price = floatValue } }

                    "taxes" ->
                        UpdateLine index { line | product = { product | taxes = floatValue } }

                    "quantity" ->
                        UpdateLine index { line | quantity = floatValue }

                    _ ->
                        UpdateLine index line
    in
        tr [ class "row col-12" ]
            [ td [ class "col-3 p-0 ta-right" ] [ input [ class "col-12 ta-right", type_ "name", value name, onInput <| updateField "name" ] [] ]
            , td [ class "col-3 p-0 ta-right" ] [ input [ class "col-12 ta-right", type_ "number", value <| toString price, onInput <| updateField "price" ] [] ]
            , td [ class "col-2 p-0 ta-right" ] [ input [ class "col-12 ta-right", type_ "number", value <| toString taxes, onInput <| updateField "taxes" ] [] ]
            , td [ class "col-2 p-0 ta-right" ] [ input [ class "col-12 ta-right", type_ "number", value <| toString quantity, onInput <| updateField "quantity" ] [] ]
            , td [ style [ ( "float", "right" ) ] ]
                [ button [ onClick <| ToggleEditLine index ] [ text <| translate language Save ]
                , button [ onClick <| DeleteLine index ] [ text <| translate language Delete ]
                ]
            ]


addLineView : Language -> Currency -> Line -> Html Msg
addLineView language currency line =
    let
        { product } =
            line

        { quantity } =
            line

        updateField field value =
            let
                floatValue =
                    Result.withDefault 0 <| String.toFloat value
            in
                case field of
                    "name" ->
                        UpdateCurrentLine { line | product = { product | name = value } }

                    "price" ->
                        UpdateCurrentLine { line | product = { product | price = floatValue } }

                    "taxes" ->
                        UpdateCurrentLine { line | product = { product | taxes = floatValue } }

                    "quantity" ->
                        UpdateCurrentLine { line | quantity = floatValue }

                    _ ->
                        UpdateCurrentLine line

        inputGroup ( field, ftype ) translateId val =
            label [ class "col-sm-12 col-3" ]
                [ text <| (translate language translateId) ++ ": "
                , input
                    [ class "col-sm-12 col-12 b-none b-b-1px h4 ta-right"
                    , type_ ftype
                    , placeholder (translate language translateId)
                    , value val
                    , onInput <| updateField field
                    ]
                    []
                ]
    in
        form [ class "row", action "javascript:void(0);", onSubmit <| AddLine line ]
            [ inputGroup ( "name", "text" ) ServiceName line.product.name
            , inputGroup ( "price", "number" ) Price (toString line.product.price)
            , inputGroup ( "taxes", "number" ) Taxes (toString line.product.taxes)
            , inputGroup ( "quantity", "number" ) Quantity (toString quantity)
            , input [ type_ "submit", value "Add line", style [ ( "visibility", "hidden" ), ( "display", "none" ) ] ] []
            ]


invoiceLinesView : Language -> InvoiceLines -> Html Msg
invoiceLinesView language invoiceLines =
    let
        tableHead =
            tr [ class "row col-12" ]
                [ th [ class "col-3 p-0 ta-right" ] [ text <| translate language ServiceName ]
                , th [ class "col-3 p-0 ta-right" ] [ text <| translate language Price ]
                , th [ class "col-2 p-0 ta-right" ] [ text <| translate language Taxes ]
                , th [ class "col-2 p-0 ta-right" ] [ text <| translate language Quantity ]
                , th [ class "col-2 p-0 ta-right" ] [ text <| translate language Amount ]
                ]

        view index line =
            if line.editing then
                editLineView language ( index, line )
            else
                lineView ( index, line )

        tableBody =
            List.indexedMap view invoiceLines

        invoiceTable =
            tableHead :: tableBody
    in
        table [ class "col-12 m-b-2em" ] invoiceTable


invoiceView : Model -> Html Msg
invoiceView model =
    let
        { invoice, currentLine, currency, language, datePicker } =
            model

        { invoicer, customer, invoicelines } =
            invoice

        inputText val =
            input [ class "b-none col-12 col-sm-12 d-block h4 m-tb-1em", type_ "text", value val ] []

        deduction =
            deductions invoice.deduction invoicelines

        subtotalInvoice =
            toCurrency ( currency, subtotal invoicelines )

        taxesInvoice =
            toCurrency ( currency, taxes invoicelines )

        deductionInvoice =
            toCurrency ( currency, deduction )

        totalInvoice =
            toCurrency ( currency, (total invoicelines) - deduction )
    in
        div [ class "wrapper" ]
            [ toolbar model
            , div [ id "invoice" ]
                [ invoiceHeader language invoicer
                , div [ class "row p-lr-3em p-tb-1-5em" ]
                    [ div [ class "col-4 h5" ]
                        [ strong [] [ text <| (translate language BilledTo) ++ ": " ]
                        , contactInfoView language customer
                        ]
                    , div [ class "col-4 h5" ]
                        [ strong [] [ text <| (translate language InvoiceNumber) ++ ": " ]
                        , inputText "#000001"
                        , p [] [ strong [] [ text <| (translate language DateOfIssue) ++ ": " ] ]
                        , DatePicker.view datePicker |> Html.map ToDatePicker
                        ]
                    , div [ class "col-4" ]
                        [ p [ class "ta-right" ] [ text <| (translate language InvoiceTotal) ++ ": " ]
                        , h1 [ class "ta-right h1 total" ] [ text <| totalInvoice ]
                        ]
                    ]
                , hr [ class "m-lr-3em b-none b-b-1px" ] []
                , div [ class "p-lr-3em p-b-1em" ]
                    [ div [ class "h5" ]
                        [ p [ class "h3" ] [ text <| translate language ProjectBreakdown ]
                        , invoiceLinesView language invoicelines
                        ]
                    ]
                , div [ class "p-lr-3em p-b-1em no-print" ] [ addLineView language currency currentLine ]
                , div [ class "p-lr-3em" ]
                    [ p [ class "ta-right p" ] [ text <| (translate language Subtotal) ++ ": " ++ subtotalInvoice ]
                    , p [ class "ta-right p" ] [ text <| (translate language Taxes) ++ ": " ++ taxesInvoice ]
                    , case invoice.deduction of
                        Just percentage ->
                            div [ class "ta-right p" ]
                                [ label [ class "no-print" ]
                                    [ text <| (translate language Deductions) ++ ": "
                                    , input [ class "ta-right", type_ "number", value (toString percentage), onInput (\val -> val |> String.toFloat |> Result.withDefault 0 |> SetDeduction) ] []
                                    ]
                                , p [] [ text <| (translate language Deductions) ++ ": " ++ deductionInvoice ]
                                ]

                        _ ->
                            text ""
                    ]
                , p [ class "p-lr-3em ta-right" ] [ strong [] [ text <| (translate language Total) ++ ": " ++ totalInvoice ] ]
                , footer [ class "footer p-1em p-lr-3em" ]
                    [ p [ class "h6 ta-justify" ]
                        [ text
                            """IMPORTANT: The above invoice may be paid by Bank Transfer.
                      Payment is due within 30 days from the date of this invoice, late payment is subject to a fee of 5% per month."""
                        ]
                    , p [ class "ta-center copyright h6" ] [ text "Gabriel Perales ® 2017" ]
                    ]
                ]
            ]
