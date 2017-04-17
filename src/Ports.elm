port module Ports exposing (..)

import Json.Encode


port print : () -> Cmd msg


port saveInvoicerDetails : String -> Cmd msg


port saveCurrency : String -> Cmd msg


port saveLanguage : String -> Cmd msg


port saveDeduction : Maybe Float -> Cmd msg


port createInvoice : () -> Cmd msg


port saveInvoice : () -> Cmd msg


port deleteInvoice : String -> Cmd msg


port getInvoice : String -> Cmd msg


port getInvoices : () -> Cmd msg


port invoice : (Json.Encode.Value -> msg) -> Sub msg


port invoices : (Json.Encode.Value -> msg) -> Sub msg
