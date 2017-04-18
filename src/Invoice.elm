module Invoice exposing (..)

import Json.Encode as Encode exposing (Value)
import Types exposing (Invoice)
import ContactDetails
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
                        float <| Date.toTime date

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
