module Views exposing (..)

import Html exposing (..)
import Html.Attributes exposing (type_, name, placeholder, value, action, id, class, style)
import Html.Events exposing (onSubmit, onInput, onClick, onDoubleClick)
import Types exposing (ContactDetails, InvoiceLines, Line, Msg(..), Currency(..), Model)
import InvoiceHelpers exposing (currencySymb, subtotal, taxes, total)
import Date
import Helpers exposing (toFixed)
import I18n exposing (translate, TranslationId(..), Language(..))


toolbar : Language -> Html Msg
toolbar language =
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
        , button [ onClick PrintPort ] [ text <| translate language Print ]
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
            , div [ class "col-4 ta-right" ]
                [ inputDefault phone <| \value -> UpdateInvoicer { invoicer | phone = value }
                , inputDefault email <| \value -> UpdateInvoicer { invoicer | email = value }
                , inputDefault website <| \value -> UpdateInvoicer { invoicer | website = value }
                ]
            , div [ class "col-4 ta-right" ]
                [ inputDefault address.street <| \value -> UpdateInvoicer { invoicer | address = { address | street = value } }
                , inputDefault address.city <| \value -> UpdateInvoicer { invoicer | address = { address | city = value } }
                , inputDefault address.zip <| \value -> UpdateInvoicer { invoicer | address = { address | zip = value } }
                ]
            ]


contactInfoView : Language -> ContactDetails -> Html Msg
contactInfoView language { name, taxes_id, address } =
    let
        inputText val =
            input [ class "b-none h4", type_ "text", value val ] []
    in
        div []
            [ p []
                [ text <| (translate language Name) ++ " :"
                , inputText name
                ]
            , p []
                [ text <| (translate language TaxId) ++ ": "
                , inputText taxes_id
                ]
            , p [] [ text <| (translate language Address) ++ ": " ]
            , div [ class "p-lr-1em" ]
                ([ address.street, address.city, address.zip ]
                    |> List.map inputText
                    |> List.intersperse (br [] [])
                )
            ]


lineView : ( Int, Line ) -> Html Msg
lineView ( index, { product, quantity } ) =
    let
        { name, price, taxes } =
            product
    in
        tr [ class "row col-12", onDoubleClick <| ToggleEditLine index ]
            [ td [ class "col-3 p-0 ta-right" ] [ text name ]
            , td [ class "col-3 p-0 ta-right" ] [ text <| toString price ]
            , td [ class "col-3 p-0 ta-right" ] [ text <| (toString taxes) ++ " %" ]
            , td [ class "col-3 p-0 ta-right" ] [ text <| toString quantity ]
            , td [] []
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
            [ td [ class "col-3 p-0 ta-right" ] [ input [ class "ta-right", type_ "name", value <| toString name, onInput <| updateField "name" ] [] ]
            , td [ class "col-3 p-0 ta-right" ] [ input [ class "ta-right", type_ "number", value <| toString price, onInput <| updateField "price" ] [] ]
            , td [ class "col-3 p-0 ta-right" ] [ input [ class "ta-right", type_ "number", value <| toString taxes, onInput <| updateField "taxes" ] [] ]
            , td [ class "col-3 p-0 ta-right" ] [ input [ class "ta-right", type_ "number", value <| toString quantity, onInput <| updateField "quantity" ] [] ]
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

                    "quantity" ->
                        UpdateCurrentLine { line | quantity = floatValue }

                    _ ->
                        UpdateCurrentLine line
    in
        form [ class "row", action "javascript:void(0);", onSubmit <| AddLine line ]
            [ label [ class "col-4" ]
                [ text <| (translate language ServiceName) ++ ": "
                , input
                    [ class "col-12 b-none b-b-1px h4 ta-right"
                    , type_ "text"
                    , name "productName"
                    , placeholder "Product Name"
                    , value line.product.name
                    , onInput <| updateField "name"
                    ]
                    []
                ]
            , label [ class "col-4" ]
                [ text <| (translate language Price) ++ " (" ++ (currencySymb currency) ++ "): "
                , input
                    [ class "col-12 b-none b-b-1px h4 ta-right"
                    , type_ "number"
                    , name "productPrice"
                    , placeholder "Price"
                    , value <| toString line.product.price
                    , onInput <| updateField "price"
                    ]
                    []
                ]
            , label [ class "col-4" ]
                [ text <| (translate language Quantity) ++ ": "
                , input
                    [ class "col-12 b-none b-b-1px h4 ta-right"
                    , type_ "number"
                    , name "productQty"
                    , placeholder "Quantity"
                    , value <| toString quantity
                    , onInput <| updateField "quantity"
                    ]
                    []
                ]
            , input [ type_ "submit", value "Add line", style [ ( "visibility", "hidden" ), ( "display", "none" ) ] ] []
            ]


invoiceLinesView : Language -> InvoiceLines -> Html Msg
invoiceLinesView language invoiceLines =
    let
        tableHead =
            tr [ class "row col-12" ]
                [ th [ class "col-3 p-0 ta-right" ] [ text <| translate language ServiceName ]
                , th [ class "col-3 p-0 ta-right" ] [ text <| translate language Price ]
                , th [ class "col-3 p-0 ta-right" ] [ text <| translate language Taxes ]
                , th [ class "col-3 p-0 ta-right" ] [ text <| translate language Quantity ]
                , th [] []
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
invoiceView { invoicer, customer, invoice, currentLine, currency, language } =
    let
        symbol =
            currencySymb currency

        inputText val =
            input [ class "b-none col-12 d-block h4 m-tb-1em", type_ "text", value val ] []
    in
        div [ class "wrapper" ]
            [ toolbar language
            , div [ id "invoice" ]
                [ invoiceHeader language invoicer
                , div [ class "row p-lr-3em p-tb-1-5em" ]
                    [ div [ class "col-4" ]
                        [ strong [] [ text <| (translate language BilledTo) ++ ": " ]
                        , contactInfoView language customer
                        ]
                    , div [ class "col-4" ]
                        [ strong [] [ text <| (translate language InvoiceNumber) ++ ": " ]
                        , inputText "#000001"
                        , p [] [ strong [] [ text <| (translate language DateOfIssue) ++ ": " ] ]
                        , inputText "01/01/2017"
                        ]
                    , div [ class "col-4" ]
                        [ p [ class "ta-right" ] [ text <| (translate language InvoiceTotal) ++ ": " ]
                        , h1 [ class "ta-right h1 total" ] [ text <| toFixed 2 (total invoice) ++ symbol ]
                        ]
                    ]
                , hr [ class "m-lr-3em b-none b-b-1px" ] []
                , div [ class "p-lr-3em p-b-1em" ]
                    [ p [ class "h3" ] [ text <| translate language ProjectBreakdown ]
                    , invoiceLinesView language invoice
                    ]
                , div [ class "p-lr-3em p-b-1em no-print" ]
                    [ addLineView language currency currentLine
                    ]
                , p [ class "p-lr-3em ta-right" ] [ text <| (translate language Subtotal) ++ ": " ++ toFixed 2 (subtotal invoice) ++ symbol ]
                , p [ class "p-lr-3em ta-right" ] [ text <| (translate language Taxes) ++ ": " ++ toFixed 2 (taxes invoice) ++ symbol ]
                , p [ class "p-lr-3em ta-right" ] [ strong [] [ text <| (translate language Total) ++ ": " ++ toFixed 2 (total invoice) ++ symbol ] ]
                , footer [ class "footer p-1em p-lr-3em" ]
                    [ p [ class "p ta-justify" ]
                        [ text
                            """IMPORTANT: The above invoice may be paid by Bank Transfer.
                      Payment is due within 30 days from the date of this invoice, late payment is subject to a fee of 5% per month"""
                        ]
                    , p [ class "ta-center h6" ] [ text "Gabriel Perales ® 2017" ]
                    ]
                ]
            ]
