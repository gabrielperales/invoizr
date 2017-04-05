module Views exposing (..)

import Html exposing (..)
import Html.Attributes exposing (type_, name, placeholder, value, action, id, class, style)
import Html.Events exposing (onSubmit, onInput, onClick, onDoubleClick)
import Types exposing (..)
import InvoiceHelpers exposing (currencySymb, subtotal, taxes, total)
import Date
import Material
import Material.Menu as Menu
import Material.Button as Button
import Material.Textfield as Textfield
import Material.Options as Options


toolbar : Material.Model -> Html Msg
toolbar mdl =
    div [ class "no-print m-tb-1em" ]
        [ Menu.render Mdl
            [ 0 ]
            mdl
            [ Menu.ripple, Menu.bottomLeft ]
            [ Menu.item
                []
                [ text "English" ]
            , Menu.item
                [ Menu.divider ]
                [ text "Spanish" ]
            , Menu.item
                [ Menu.onSelect SavePDF ]
                [ text "Print" ]
            ]
        ]


invoiceHeader : ContactDetails -> Html Msg
invoiceHeader { name, taxes_id, phone, email, website, address } =
    let
        inputText classes val =
            input [ class ("d-block bc-transparent b-none c-white fs-0-8em " ++ classes), type_ "text", value val ] []

        inputDefault =
            inputText "m-1em"

        inputBigger =
            inputText "fs-1em m-0 m-tb-0-75em p-0 ta-left"
    in
        header [ class "row header p-tb-1-5em p-lr-3em" ]
            [ div [ class "col-4" ]
                [ inputBigger name
                , h1 [] [ text "INVOICE" ]
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


contactInfoView : ContactDetails -> Html Msg
contactInfoView { name, taxes_id, address } =
    let
        inputText val =
            input [ class "b-none fs-1em", type_ "text", value val ] []
    in
        div []
            [ p []
                [ text <| "Name: "
                , inputText name
                ]
            , p []
                [ text <| "Tax id: "
                , inputText taxes_id
                ]
            , p [] [ text <| "Address: " ]
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


editLineView : Material.Model -> ( Int, Line ) -> Html Msg
editLineView mdl ( index, line ) =
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
                    [ text "save" ]
                , Button.render Mdl
                    [ 0 ]
                    mdl
                    [ Button.raised
                    , Button.colored
                    , Options.onClick <| DeleteLine index
                    ]
                    [ text "delete" ]
                ]
            ]


addLineView : Line -> Html Msg
addLineView line =
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
                [ text "Service name: "
                , input
                    [ class "col-12 b-none b-b-1px fs-1em ta-right"
                    , type_ "text"
                    , name "productName"
                    , placeholder "Product Name"
                    , value line.product.name
                    , onInput <| updateField "name"
                    ]
                    []
                ]
            , label [ class "col-4" ]
                [ text "Service price (€): "
                , input
                    [ class "col-12 b-none b-b-1px fs-1em ta-right"
                    , type_ "number"
                    , name "productPrice"
                    , placeholder "Price"
                    , value <| toString line.product.price
                    , onInput <| updateField "price"
                    ]
                    []
                ]
            , label [ class "col-4" ]
                [ text "Quantity: "
                , input
                    [ class "col-12 b-none b-b-1px fs-1em ta-right"
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


invoiceLinesView : Material.Model -> InvoiceLines -> Html Msg
invoiceLinesView mdl invoiceLines =
    let
        tableHead =
            tr [ class "row col-12" ]
                [ th [ class "col-3 p-0 ta-right" ] [ text "Product name" ]
                , th [ class "col-3 p-0 ta-right" ] [ text "Price" ]
                , th [ class "col-3 p-0 ta-right" ] [ text "Taxes" ]
                , th [ class "col-3 p-0 ta-right" ] [ text "Quantity" ]
                , th [] []
                ]

        view index line =
            if line.editing then
                editLineView mdl ( index, line )
            else
                lineView ( index, line )

        tableBody =
            List.indexedMap view invoiceLines

        invoiceTable =
            tableHead :: tableBody
    in
        table [ class "col-12 m-b-2em" ] invoiceTable


invoiceView : Model -> Html Msg
invoiceView { invoicer, customer, invoice, currentLine, currency, mdl } =
    let
        symbol =
            currencySymb currency

        inputText val =
            input [ class "b-none col-12 d-block fs-1em m-tb-1em", type_ "text", value val ] []
    in
        div [ class "wrapper" ]
            [ toolbar mdl
            , div [ id "invoice" ]
                [ invoiceHeader invoicer
                , div [ class "row p-lr-3em p-tb-1-5em" ]
                    [ div [ class "col-4" ]
                        [ strong [] [ text "Billed to:" ]
                        , contactInfoView customer
                        ]
                    , div [ class "col-4" ]
                        [ strong [] [ text "Invoice Number" ]
                        , inputText "#000001"
                        , p [] [ strong [] [ text "Date Of Issue" ] ]
                        , inputText "01/01/2017"
                        ]
                    , div [ class "col-4" ]
                        [ p [ class "ta-right" ] [ text "Invoice total" ]
                        , h1 [ class "ta-right fs-3em total" ] [ text <| toString (total invoice) ++ symbol ]
                        ]
                    ]
                , hr [ class "m-lr-3em b-none b-b-1px" ] []
                , div [ class "p-lr-3em p-b-1em" ]
                    [ p [ class "fs-1-5em" ] [ text "PROJECT BREAKDOWN" ]
                    , invoiceLinesView mdl invoice
                    ]
                , div [ class "p-lr-3em p-b-1em no-print" ]
                    [ addLineView currentLine
                    ]
                , p [ class "p-lr-3em ta-right" ] [ text <| "Subtotal: " ++ toString (subtotal invoice) ++ symbol ]
                , p [ class "p-lr-3em ta-right" ] [ text <| "Taxes: " ++ toString (taxes invoice) ++ symbol ]
                , p [ class "p-lr-3em ta-right" ] [ strong [] [ text <| "Total: " ++ toString (total invoice) ++ symbol ] ]
                , footer [ class "footer p-1em p-lr-3em" ]
                    [ p [ class "fs-0-8em ta-justify" ]
                        [ text
                            """IMPORTANT: The above invoice may be paid by Bank Transfer.
                      Payment is due within 30 days from the date of this invoice, late payment is subject to a fee of 5% per month"""
                        ]
                    , p [ class "ta-center fs-0-6em" ] [ text "Gabriel Perales ® 2017" ]
                    ]
                ]
            ]
