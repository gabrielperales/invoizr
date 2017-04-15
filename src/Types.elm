module Types exposing (..)

import I18n exposing (Language)
import Date exposing (Date)
import DatePicker exposing (DatePicker)


type alias Model =
    { invoicer : ContactDetails
    , customer : ContactDetails
    , invoice : Invoice
    , date : Maybe Date
    , datePicker : DatePicker
    , currentLine : Line
    , currency : Currency
    , language : Language
    , deduction : Deduction
    }


type alias Flags =
    { invoicer : Maybe String
    , currency : Maybe String
    , language : Maybe String
    , deduction : Maybe String
    }


type alias Deduction =
    Maybe Float


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
    | ToDatePicker DatePicker.Msg
    | SetDate Date
    | ToggleDeductions
    | SetDeduction Float
    | PrintPort
    | NoOp
