module DatePickerHelpers exposing (..)

import Date exposing (Date, Day(..), Month(..), year, month, day)
import DatePicker exposing (defaultSettings, DatePicker)


newDatePicker : Maybe Date -> DatePicker
newDatePicker mdate =
    { defaultSettings | firstDayOfWeek = Mon, pickedDate = mdate, dateFormatter = formatDate }
        |> DatePicker.init
        |> Tuple.first


monthToInt : Month -> Int
monthToInt month =
    case month of
        Jan ->
            1

        Feb ->
            2

        Mar ->
            3

        Apr ->
            4

        May ->
            5

        Jun ->
            6

        Jul ->
            7

        Aug ->
            8

        Sep ->
            9

        Oct ->
            10

        Nov ->
            11

        Dec ->
            12


formatDate : Date -> String
formatDate date =
    [ day date, monthToInt <| month date, year date ]
        |> List.map (String.padLeft 2 '0' << toString)
        |> String.join "/"
