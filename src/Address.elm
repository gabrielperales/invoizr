module Address exposing (..)

import Json.Encode as Encode exposing (Value)
import Json.Decode as Decode exposing (field, Decoder)


encode : Address -> Value
encode address =
    let
        string =
            Encode.string
    in
        Encode.object
            [ ( "street", string address.street )
            , ( "city", string address.city )
            , ( "state", string address.state )
            , ( "country", string address.country )
            , ( "zip", string address.zip )
            ]


decoder : Decoder Address
decoder =
    let
        string =
            Decode.string
    in
        (Decode.map5 Address
            (field "street" string)
            (field "city" string)
            (field "state" string)
            (field "country" string)
            (field "zip" string)
        )


update : Msg -> Address -> Address
update msg address =
    case msg of
        Street street ->
            { address | street = street }

        City city ->
            { address | city = city }

        State state ->
            { address | state = state }

        Country country ->
            { address | country = country }

        Zip zip ->
            { address | zip = zip }


type alias Address =
    { street : String
    , city : String
    , state : String
    , country : String
    , zip : String
    }


type Msg
    = Street String
    | City String
    | State String
    | Country String
    | Zip String
