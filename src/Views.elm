module Views exposing (..)

import Html exposing (..)
import Html.Attributes exposing (type_, name, placeholder, value, action, id, class, style)
import Html.Events exposing (onSubmit, onInput, onClick, onDoubleClick)
import Types exposing (ContactDetails, InvoiceLines, Line, Msg(..), Model)
import InvoiceHelpers exposing (currencySymb, subtotal, taxes, total)
import Date
import Material
import Material.Menu as Menu
import Material.Button as Button
import Material.Textfield as Textfield
import Material.Options as Options
import Helpers exposing (toFixed)
import I18n exposing (translate, TranslationId(..), Language(..))


toolbar : Language -> Material.Model -> Html Msg
toolbar language mdl =
    div [ class "no-print m-tb-1em" ]
        [ Menu.render Mdl
            [ 0 ]
            mdl
            [ Menu.ripple, Menu.bottomLeft ]
            [ Menu.item
                [ Menu.onSelect <| SetLanguage EN ]
                [ text <| translate language English ]
            , Menu.item
                [ Menu.divider
                , Menu.onSelect <| SetLanguage ES
                ]
                [ text <| translate language Spanish ]
            , Menu.item
                [ Menu.onSelect SavePDF ]
                [ text <| translate language Print ]
            ]
        ]


invoiceHeader : Language -> ContactDetails -> Html Msg
invoiceHeader language { name, taxes_id, phone, email, website, address } =
    let
        inputText classes val =
            input [ class ("d-block bc-transparent b-none c-white p " ++ classes), type_ "text", value val ] []

        inputDefault =
            inputText "m-1em"

        inputBigger =
            inputText "h4 m-0 m-tb-0-75em p-0 ta-left"
    in
        header [ class "row header p-tb-1-5em p-lr-3em" ]
            [ div [ class "col-4" ]
                [ inputBigger name
                , h1 [] [ text <| translate language Invoice ]
                ]
            , div [ class "col-4 ta-right" ]
                [ inputDefault phone
                , inputDefault email
                , inputDefault website
                ]
            , div [ class "col-4 ta-right" ]
                [ inputDefault address.street
                , inputDefault address.city
                , inputDefault address.zip
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


editLineView : Language -> Material.Model -> ( Int, Line ) -> Html Msg
editLineView language mdl ( index, line ) =
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
                [ Button.render Mdl
                    [ 0 ]
                    mdl
                    [ Button.raised
                    , Button.colored
                    , Options.onClick <| ToggleEditLine index
                    ]
                    [ text <| translate language Save ]
                , Button.render Mdl
                    [ 0 ]
                    mdl
                    [ Button.raised
                    , Button.colored
                    , Options.onClick <| DeleteLine index
                    ]
                    [ text <| translate language Delete ]
                ]
            ]


addLineView : Language -> Line -> Html Msg
addLineView language line =
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
                [ text <| (translate language Price) ++ " (€): "
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


invoiceLinesView : Language -> Material.Model -> InvoiceLines -> Html Msg
invoiceLinesView language mdl invoiceLines =
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
                editLineView language mdl ( index, line )
            else
                lineView ( index, line )

        tableBody =
            List.indexedMap view invoiceLines

        invoiceTable =
            tableHead :: tableBody
    in
        table [ class "col-12 m-b-2em" ] invoiceTable


invoiceView : Model -> Html Msg
invoiceView { invoicer, customer, invoice, currentLine, currency, language, mdl } =
    let
        symbol =
            currencySymb currency

        inputText val =
            input [ class "b-none col-12 d-block h4 m-tb-1em", type_ "text", value val ] []
    in
        div [ class "wrapper" ]
            [ toolbar language mdl
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
                    , invoiceLinesView language mdl invoice
                    ]
                , div [ class "p-lr-3em p-b-1em no-print" ]
                    [ addLineView language currentLine
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
