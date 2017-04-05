port module Main exposing (..)

import InvoiceHelpersTests
import Test.Runner.Node exposing (run, TestProgram)
import Json.Encode exposing (Value)


main : TestProgram
main =
    run emit InvoiceHelpersTests.all


port emit : ( String, Value ) -> Cmd msg
