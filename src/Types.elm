module Types exposing (..)

import I18n exposing (Language)
import Date exposing (Date)
import DatePicker exposing (DatePicker)
import ContactDetails exposing (ContactDetails)
import Address exposing (Address)
import Invoice exposing (Invoice, Line, Currency)


type alias Model =
    { invoice : Invoice
    , datePicker : DatePicker
    , currentLine : Line
    , currency : Currency
    , language : Language
    , invoices : List Invoice
    , agreetments : String
    }


type alias Flags =
    { invoicer : Maybe String
    , currency : Maybe String
    , language : Maybe String
    , deduction : Maybe String
    , agreetments : Maybe String
    }



-- Messages


type Msg
    = AddLine Line
    | UpdateLine Int Line
    | ToggleEditLine Int
    | DeleteLine Int
    | UpdateCurrentLine Line
    | UpdateInvoicer ContactDetails
    | UpdateCustomer ContactDetails
    | SetLanguage Language
    | SetCurrency Currency
    | ToDatePicker DatePicker.Msg
    | SetDate Date
    | ToggleDeductions
    | SetDeduction Float
    | SavePort Invoice
    | PrintPort
    | GetInvoicesPort
    | SetInvoices (List Invoice)
    | SetInvoice (Maybe Invoice)
    | DeleteInvoice Invoice
    | UpdateAgreetments String
    | NoOp
