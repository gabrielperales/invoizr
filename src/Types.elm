module Types exposing (..)

import I18n exposing (Language)


type alias Model =
    { invoicer : ContactDetails
    , customer : ContactDetails
    , invoice : Invoice
    , currentLine : Line
    , currency : Currency
    , language : Language
    }


type alias Flags =
    { invoicerjson : Maybe String }


type Currency
    = EUR
    | USD
    | GBP


type alias ContactDetails =
    { name : String
    , taxes_id : String
    , phone : String
    , email : String
    , website : String
    , address : Address
    }


type alias Address =
    { street : String
    , city : String
    , state : String
    , country : String
    , zip : String
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


type alias Invoice =
    InvoiceLines



-- Messages


type Msg
    = AddLine Line
    | UpdateLine Int Line
    | ToggleEditLine Int
    | DeleteLine Int
    | UpdateCurrentLine Line
    | UpdateInvoicer ContactDetails
    | SetLanguage Language
    | SetCurrency Currency
    | PrintPort
