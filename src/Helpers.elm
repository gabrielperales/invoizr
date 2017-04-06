module Helpers exposing (..)


toFixed : Int -> Float -> String
toFixed decimals number =
    let
        zpadding =
            String.padRight decimals '0'

        parts =
            String.split "." <| toString number

        join =
            String.join "."
    in
        case parts of
            part1 :: [] ->
                join [ part1, zpadding "" ]

            part1 :: part2 :: [] ->
                join [ part1, zpadding <| String.left decimals part2 ]

            _ ->
                join [ "0", zpadding "" ]
