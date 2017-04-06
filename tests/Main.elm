port module Main exposing (..)

import InvoiceHelpersTests
import HelpersTests
import Test.Runner.Node exposing (run, TestProgram)
import Json.Encode exposing (Value)
import Test exposing (concat)


main : TestProgram
main =
    let
        tests =
            concat
                [ InvoiceHelpersTests.all
                , HelpersTests.all
                ]
    in
        run emit tests


port emit : ( String, Value ) -> Cmd msg
