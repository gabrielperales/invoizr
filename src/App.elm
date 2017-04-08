module App exposing (..)

import Types exposing (Model, Flags, Line, Product, Msg(..), Currency(..))
import Html exposing (programWithFlags)
import Views exposing (invoiceView)
import InvoiceHelpers exposing (newContact, newEmptyLine)
import Ports exposing (..)
import I18n exposing (Language(..))
import ContactDetails


model : Model
model =
    { invoicer = newContact
    , customer = newContact
    , invoice = []
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
                update (UpdateInvoicer invoicer) model

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
