module InvoiceHelpersTests exposing (..)

import InvoiceHelpers exposing (..)
import Invoice exposing (Product, Line, InvoiceLines)
import Test exposing (..)
import Expect


dummyProduct =
    Product "product" 1 21


dummyLine =
    Line dummyProduct 5 False


dummyInvoiceLines =
    []


all : Test
all =
    describe "InvoiceHelpers Test Suite"
        [ describe "Unit test examples"
            [ test "Add new line to the invoice" <|
                \() ->
                    let
                        invoiceList =
                            []
                    in
                        Expect.equal 1 (List.length <| addLine dummyLine invoiceList)
            , test "Total line" <|
                \() ->
                    let
                        newLine =
                            Line (Product "product" 1 21) 5 False
                    in
                        Expect.equal 5 (subtotalLine newLine)
            , test "Add product to Line" <|
                \() ->
                    let
                        line =
                            Line dummyProduct 1 False
                    in
                        Expect.equal 2 (.quantity <| addProduct line)
            , test "Remove product to Line" <|
                \() ->
                    let
                        line =
                            Line dummyProduct 1 False
                    in
                        Expect.equal 0 (.quantity <| removeProduct line)
            , test "Remove product when a line has no quantity" <|
                \() ->
                    let
                        line =
                            Line dummyProduct 0 False
                    in
                        Expect.equal 0 (.quantity <| removeProduct line)
            , test "Update line quantity" <|
                \() ->
                    let
                        line =
                            Line dummyProduct 0.5 False
                    in
                        Expect.equal 1.0 (.quantity <| updateLineQuantity 1.0 line)
            , test "Add quantity to line" <|
                \() ->
                    let
                        line =
                            Line dummyProduct 0.5 False
                    in
                        Expect.equal 1.0 (.quantity <| addQuantity 0.5 line)
            , test "Remove quantity to line" <|
                \() ->
                    let
                        line =
                            Line dummyProduct 0.5 False
                    in
                        Expect.equal 0.25 (.quantity <| removeQuantity 0.25 line)
            , test "Lines subtotal" <|
                \() ->
                    let
                        lines =
                            [ Line dummyProduct 1 False, Line dummyProduct 3 False ]
                    in
                        Expect.equal 4 (subtotal lines)
            , test "Total line" <|
                \() ->
                    let
                        line =
                            Line dummyProduct 1 False
                    in
                        Expect.equal 1.21 (totalLine line)
            , test "Taxes line" <|
                \() ->
                    let
                        line =
                            Line dummyProduct 1 False
                    in
                        Expect.equal 0.21 (taxesLine line)
            , test "Taxes" <|
                \() ->
                    let
                        lines =
                            [ Line dummyProduct 1 False, Line dummyProduct 3 False ]
                    in
                        Expect.equal 0.84 (taxes lines)
            , test "Total" <|
                \() ->
                    let
                        lines =
                            [ Line (Product "A" 1 50) 1 False, Line (Product "B" 2 25) 1 False ]
                    in
                        Expect.equal 4.0 (total lines)
            ]
        ]
