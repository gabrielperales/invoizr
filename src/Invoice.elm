module Invoice exposing (..)

import Json.Encode as Encode exposing (Value)
import Json.Decode as Decode exposing (Decoder, field)
import ContactDetails exposing (ContactDetails)
import Helpers exposing (decodeDate)
import Date exposing (Date)


encode : Invoice -> Value
encode invoice =
    let
        string =
            Encode.string

        bool =
            Encode.bool

        list =
            Encode.list

        float =
            Encode.float

        contactDetails =
            ContactDetails.encode

        null =
            Maybe.withDefault Encode.null
    in
        Encode.object
            [ ( "_id", null <| Maybe.map string invoice.id )
            , ( "_rev", null <| Maybe.map string invoice.rev )
            , ( "invoicer", contactDetails invoice.invoicer )
            , ( "customer", contactDetails invoice.customer )
            , ( "invoicelines"
              , invoice.invoicelines
                    |> List.map
                        (\line ->
                            Encode.object
                                [ ( "product"
                                  , Encode.object
                                        [ ( "name", string line.product.name )
                                        , ( "price", float line.product.price )
                                        , ( "taxes", float line.product.taxes )
                                        ]
                                  )
                                , ( "quantity", float line.quantity )
                                , ( "editing", bool line.editing )
                                ]
                        )
                    |> list
              )
            , ( "date", null <| Maybe.map (string << toString) <| invoice.date )
            , ( "deduction", null <| Maybe.map float invoice.deduction )
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


type alias Invoice =
    { id : Maybe String
    , rev : Maybe String
    , invoicer : ContactDetails
    , customer : ContactDetails
    , invoicelines : InvoiceLines
    , date : Maybe Date
    , deduction : Maybe Deduction
    }


type alias Product =
    { name : String
    , price : Float
    , taxes : Float
    }


type alias Line =
    { product : Product
    , quantity : Float
    , editing : Bool
    }


type alias InvoiceLines =
    List Line


type alias Deduction =
    Float


type Currency
    = EUR
    | USD
    | GBP
