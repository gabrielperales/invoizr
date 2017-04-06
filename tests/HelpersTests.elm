module HelpersTests exposing (..)

import Helpers exposing (..)
import Test exposing (..)
import Expect


all : Test
all =
    describe "Sample Test Suite"
        [ describe "Unit test examples"
            [ test "toFixed truncating decimals" <|
                \() ->
                    Expect.equal "1.12" <| toFixed 2 1.12111
            , test "toFixed extending decimals" <|
                \() ->
                    Expect.equal "1.100" <| toFixed 3 1.1
            ]
        ]
