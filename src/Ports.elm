port module Ports exposing (..)


port print : () -> Cmd msg


port saveInvoicerDetails : String -> Cmd msg


port saveCurrency : String -> Cmd msg


port saveLanguage : String -> Cmd msg


port saveDeduction : Maybe Float -> Cmd msg
