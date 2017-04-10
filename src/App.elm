module App exposing (..)

import Types exposing (Model, Flags, Line, Product, Msg(..), Currency(..))
import Html exposing (programWithFlags)
import Views exposing (invoiceView)
import InvoiceHelpers exposing (exampleContact, newContact, newEmptyLine)
import Ports exposing (..)
import I18n exposing (Language(..))
import ContactDetails
import DatePicker exposing (defaultSettings)
import Date
import Task


model : Model
model =
    { invoicer = exampleContact
    , customer = newContact
    , invoice = []
    , date = Nothing
    , datePicker = Tuple.first (DatePicker.init defaultSettings)
    , currentLine = newEmptyLine
    , currency = EUR
    , language = EN
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AddLine line ->
            { model | invoice = line :: model.invoice, currentLine = newEmptyLine } ! [ Cmd.none ]

        UpdateCurrentLine line ->
            { model | currentLine = line } ! [ Cmd.none ]

        UpdateInvoicer invoicer ->
            { model | invoicer = invoicer } ! [ saveInvoicerDetails <| ContactDetails.encode invoicer ]

        ToggleEditLine index ->
            let
                update idx item =
                    if idx == index then
                        { item | editing = not item.editing }
                    else
                        item
            in
                { model | invoice = List.indexedMap update model.invoice } ! [ Cmd.none ]

        UpdateLine index line ->
            let
                update idx item =
                    if idx == index then
                        line
                    else
                        item
            in
                { model | invoice = List.indexedMap update model.invoice } ! [ Cmd.none ]

        DeleteLine index ->
            let
                filter ( idx, item ) =
                    if idx == index then
                        Nothing
                    else
                        Just item
            in
                { model | invoice = List.filterMap filter <| List.indexedMap (,) model.invoice } ! [ Cmd.none ]

        SetLanguage language ->
            { model | language = language } ! [ Cmd.none ]

        SetCurrency currency ->
            { model | currency = currency } ! [ Cmd.none ]

        ToDatePicker msg_ ->
            let
                ( newDatePicker, datePickerFx, mDate ) =
                    DatePicker.update msg_ model.datePicker

                date =
                    case mDate of
                        Nothing ->
                            model.date

                        date ->
                            date
            in
                { model | date = date, datePicker = newDatePicker } ! [ Cmd.map ToDatePicker datePickerFx ]

        SetDate date ->
            let
                datePicker =
                    Tuple.first <| DatePicker.init { defaultSettings | pickedDate = Just date }
            in
                { model | date = Just date, datePicker = datePicker } ! [ Cmd.none ]

        PrintPort ->
            model ! [ print () ]


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        { invoicerjson } =
            flags

        invoicerstr =
            Maybe.withDefault "" invoicerjson
    in
        case (ContactDetails.decode invoicerstr) of
            Ok invoicer ->
                let
                    ( newModel, cmd ) =
                        update (UpdateInvoicer invoicer) model

                    now =
                        Task.perform (\now -> SetDate now) Date.now
                in
                    newModel ! [ cmd, now ]

            Err _ ->
                model ! [ Cmd.none ]


main : Program Flags Model Msg
main =
    programWithFlags
        { init = init
        , view = invoiceView
        , subscriptions = always Sub.none
        , update = update
        }
