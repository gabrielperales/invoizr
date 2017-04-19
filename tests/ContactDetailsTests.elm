module ContactDetailsTests exposing (..)

import ContactDetails exposing (..)
import Test exposing (..)
import Expect
import InvoiceHelpers exposing (exampleContact)
import Fixtures exposing (contactDetails)
import Json.Encode as Encode


all : Test
all =
    describe "ContactDetails Test Suite"
        [ describe "decode"
            [ test "Decoding a contact json string in to a ContactDetails type" <|
                \() ->
                    Expect.equal (Ok exampleContact) <| decode contactDetails
            , test "Encoding a type ContactDetails in to a json string" <|
                \() ->
                    let
                        blanks =
                            \c -> not ((c == ' ') || (c == '\n'))
                    in
                        Expect.equal (String.filter blanks contactDetails)
                            (encode exampleContact
                                |> Encode.encode 0
                                |> String.filter blanks
                            )
            ]
        ]
