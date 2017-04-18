module ContactDetails exposing (..)

import Json.Encode as Encode exposing (Value)
import Json.Decode as Decode exposing (Decoder, field)
import Types exposing (ContactDetails, Address)


encode : ContactDetails -> Value
encode details =
    let
        string =
            Encode.string
    in
        Encode.object
            [ ( "name", string details.name )
            , ( "taxes_id", string details.taxes_id )
            , ( "phone", string details.phone )
            , ( "email", string details.email )
            , ( "website", string details.website )
            , ( "address"
              , Encode.object
                    [ ( "street", string details.address.street )
                    , ( "city", string details.address.city )
                    , ( "state", string details.address.state )
                    , ( "country", string details.address.country )
                    , ( "zip", string details.address.zip )
                    ]
              )
            ]


decoder : Decoder ContactDetails
decoder =
    let
        string =
            Decode.string
    in
        (Decode.map6 ContactDetails
            (field "name" string)
            (field "taxes_id" string)
            (field "phone" string)
            (field "email" string)
            (field "website" string)
            (field "address"
                (Decode.map5 Address
                    (field "street" string)
                    (field "city" string)
                    (field "state" string)
                    (field "country" string)
                    (field "zip" string)
                )
            )
        )


decode : String -> Result String ContactDetails
decode invoicer =
    Decode.decodeString decoder invoicer
