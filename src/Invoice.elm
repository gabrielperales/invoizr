module Invoice exposing (..)

import Json.Encode as Encode exposing (Value)
import Json.Decode as Decode exposing (Decoder, field)
import Types exposing (Invoice, Line, Product)
import ContactDetails
import Helpers exposing (decodeDate)
import Date


encode : Invoice -> Value
encode invoice =
    let
        string =
            Encode.string

        list =
            Encode.list

        float =
            Encode.float

        contactDetails =
            ContactDetails.encode
    in
        Encode.object
            [ ( "invoicer", contactDetails invoice.invoicer )
            , ( "customer", contactDetails invoice.customer )
            , ( "invoicelines"
              , invoice.invoicelines
                    |> List.map
                        (\line ->
                            Encode.object
                                [ ( "quantity", float line.quantity )
                                , ( "product"
                                  , Encode.object
                                        [ ( "name", string line.product.name )
                                        , ( "price", float line.product.price )
                                        , ( "taxes", float line.product.taxes )
                                        ]
                                  )
                                ]
                        )
                    |> list
              )
            , ( "date"
              , case invoice.date of
                    Just date ->
                        string <| toString date

                    _ ->
                        Encode.null
              )
            , ( "deduction"
              , case invoice.deduction of
                    Just deduction ->
                        float deduction

                    _ ->
                        Encode.null
              )
            ]


decoder : Decoder Invoice
decoder =
    let
        string =
            Decode.string

        float =
            Decode.float

        nullable =
            Decode.nullable

        contactDetails =
            ContactDetails.decoder
    in
        (Decode.map7 Invoice
            (field "_id" (nullable string))
            (field "_rev" (nullable string))
            (field "invoicer" contactDetails)
            (field "customer" contactDetails)
            (field "invoicelines"
                (Decode.list
                    (Decode.map3 Line
                        (field "product"
                            (Decode.map3 Product
                                (field "name" string)
                                (field "price" float)
                                (field "taxes" float)
                            )
                        )
                        (field "quantity" float)
                        (field "editing" Decode.bool)
                    )
                )
            )
            (field "date" (nullable decodeDate))
            (field "deduction" (nullable float))
        )


decode : String -> Result String Invoice
decode invoice =
    Decode.decodeString decoder invoice
