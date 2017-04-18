module App exposing (..)

import Types exposing (Model, Flags, Line, Product, Msg(..), Currency(..))
import Html exposing (programWithFlags)
import Views exposing (invoiceView)
import InvoiceHelpers exposing (exampleContact, newContact, newEmptyLine, stringToCurrency, stringToLanguage)
import Ports exposing (..)
import I18n exposing (Language(..))
import ContactDetails
import Invoice
import Date
import DatePicker
import DatePickerHelpers exposing (..)
import Task exposing (Task)
import Json.Encode as Encode


model : Model
model =
    { invoice =
        { id = Nothing
        , rev = Nothing
        , invoicelines = []
        , invoicer = exampleContact
        , customer = newContact
        , date = Nothing
        , deduction = Nothing
        }
    , datePicker = newDatePicker Nothing
    , currentLine = newEmptyLine
    , currency = EUR
    , language = EN
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        { invoice } =
            model
    in
        case msg of
            AddLine line ->
                { model | invoice = { invoice | invoicelines = line :: invoice.invoicelines }, currentLine = newEmptyLine } ! [ Cmd.none ]

            UpdateCurrentLine line ->
                { model | currentLine = line } ! [ Cmd.none ]

            UpdateInvoicer invoicer ->
                { model | invoice = { invoice | invoicer = invoicer } }
                    ! [ ContactDetails.encode invoicer
                            |> Encode.encode 0
                            |> saveInvoicerDetails
                      ]

            ToggleEditLine index ->
                let
                    update idx item =
                        if idx == index then
                            { item | editing = not item.editing }
                        else
                            item
                in
                    { model | invoice = { invoice | invoicelines = List.indexedMap update invoice.invoicelines } } ! [ Cmd.none ]

            UpdateLine index line ->
                let
                    update idx item =
                        if idx == index then
                            line
                        else
                            item
                in
                    { model | invoice = { invoice | invoicelines = List.indexedMap update invoice.invoicelines } } ! [ Cmd.none ]

            DeleteLine index ->
                let
                    filter ( idx, item ) =
                        if idx == index then
                            Nothing
                        else
                            Just item
                in
                    { model | invoice = { invoice | invoicelines = List.filterMap filter <| List.indexedMap (,) invoice.invoicelines } } ! [ Cmd.none ]

            SetLanguage language ->
                { model | language = language } ! [ saveLanguage <| toString language ]

            SetCurrency currency ->
                { model | currency = currency } ! [ saveCurrency <| toString currency ]

            ToDatePicker msg_ ->
                let
                    ( newDatePicker, datePickerFx, mDate ) =
                        DatePicker.update msg_ model.datePicker

                    date =
                        case mDate of
                            Nothing ->
                                model.invoice.date

                            date ->
                                date
                in
                    { model | invoice = { invoice | date = date }, datePicker = newDatePicker } ! [ Cmd.map ToDatePicker datePickerFx ]

            SetDate date ->
                { model | invoice = { invoice | date = Just date }, datePicker = newDatePicker <| Just date } ! [ Cmd.none ]

            ToggleDeductions ->
                let
                    deduction =
                        case invoice.deduction of
                            Just _ ->
                                Nothing

                            _ ->
                                Just 0
                in
                    { model | invoice = { invoice | deduction = deduction } } ! [ saveDeduction deduction ]

            SetDeduction deduction ->
                { model | invoice = { invoice | deduction = Just deduction } } ! [ saveDeduction <| Just deduction ]

            SavePort invoice ->
                model ! [ invoice |> Invoice.encode |> createInvoice ]

            PrintPort ->
                model ! [ print () ]

            NoOp ->
                model ! []


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        updateDate =
            Task.perform SetDate Date.now

        updateCurrency =
            flags.currency
                |> Maybe.withDefault ""
                |> stringToCurrency
                |> Result.withDefault model.currency
                |> Task.succeed
                |> Task.perform SetCurrency

        updateLanguage =
            flags.language
                |> Maybe.withDefault ""
                |> stringToLanguage
                |> Result.withDefault model.language
                |> Task.succeed
                |> Task.perform SetLanguage

        updateInvoicer =
            flags.invoicer
                |> Maybe.withDefault ""
                |> ContactDetails.decode
                |> Result.withDefault model.invoice.invoicer
                |> Task.succeed
                |> Task.perform UpdateInvoicer

        updateDeduction =
            (case flags.deduction of
                Just deduction ->
                    Task.succeed (Result.withDefault 0 <| String.toFloat deduction)

                _ ->
                    Task.fail "not stored deduction"
            )
                |> Task.attempt
                    (\result ->
                        case result of
                            Ok deduction ->
                                SetDeduction deduction

                            _ ->
                                NoOp
                    )
    in
        model ! [ updateDate, updateCurrency, updateLanguage, updateInvoicer, updateDeduction ]


main : Program Flags Model Msg
main =
    programWithFlags
        { init = init
        , view = invoiceView
        , subscriptions = always Sub.none
        , update = update
        }
