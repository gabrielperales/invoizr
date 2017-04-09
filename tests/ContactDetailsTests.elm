module ContactDetailsTests exposing (..)

import ContactDetails exposing (..)
import Test exposing (..)
import Expect
import InvoiceHelpers exposing (newContact)
import Fixtures exposing (contactDetails)


all : Test
all =
    describe "ContactDetails Test Suite"
        [ describe "decode"
            [ test "Decoding a contact json string in to a ContactDetails type" <|
                \() ->
                    Expect.equal (Ok newContact) <| decode contactDetails
            , test "Encoding a type ContactDetails in to a json string" <|
                \() ->
                    let
                        blanks =
                            \c -> not ((c == ' ') || (c == '\n'))
                    in
                        Expect.equal (String.filter blanks contactDetails) (String.filter blanks <| encode newContact)
            ]
        ]