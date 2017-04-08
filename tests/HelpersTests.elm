module HelpersTests exposing (..)

import Helpers exposing (..)
import Test exposing (..)
import Expect


all : Test
all =
    describe "Helpers Test Suite"
        [ describe "toFixed : Int -> Float -> String"
            [ test "toFixed truncating decimals" <|
                \() ->
                    Expect.equal "1.12" <| toFixed 2 1.12111
            , test "toFixed extending decimals" <|
                \() ->
                    Expect.equal "1.100" <| toFixed 3 1.1
            ]
        ]
