module ContactDetails exposing (..)

import Json.Encode as Encode exposing (Value)
import Json.Decode as Decode exposing (Decoder, field)
import Address exposing (Address)


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
            , ( "address", Address.encode details.address )
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
            (field "address" Address.decoder)
        )


decode : String -> Result String ContactDetails
decode invoicer =
    Decode.decodeString decoder invoicer


update : Msg -> ContactDetails -> ContactDetails
update msg contactDetails =
    case msg of
        Name name ->
            { contactDetails | name = name }

        Taxes_id taxes_id ->
            { contactDetails | taxes_id = taxes_id }

        Phone phone ->
            { contactDetails | phone = phone }

        Email email ->
            { contactDetails | email = email }

        Website website ->
            { contactDetails | website = website }

        Address address ->
            { contactDetails | address = address }


updateName : String -> ContactDetails -> ContactDetails
updateName =
    update << Name


updateTaxes_id : String -> ContactDetails -> ContactDetails
updateTaxes_id =
    update << Taxes_id


updatePhone : String -> ContactDetails -> ContactDetails
updatePhone =
    update << Phone


updateEmail : String -> ContactDetails -> ContactDetails
updateEmail =
    update << Email


updateWebsite : String -> ContactDetails -> ContactDetails
updateWebsite =
    update << Website


updateAddress : Address -> ContactDetails -> ContactDetails
updateAddress =
    update << Address


type alias ContactDetails =
    { name : String
    , taxes_id : String
    , phone : String
    , email : String
    , website : String
    , address : Address
    }


type Msg
    = Name String
    | Taxes_id String
    | Phone String
    | Email String
    | Website String
    | Address Address
