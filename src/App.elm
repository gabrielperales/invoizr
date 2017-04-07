module App exposing (..)

import Types exposing (Model, Line, Product, Msg(..), Currency(..))
import Html exposing (program)
import Views exposing (invoiceView)
import InvoiceHelpers exposing (newContact, newEmptyLine)
import Ports exposing (..)
import I18n exposing (Language(..))


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

        PrintPort ->
            model ! [ print () ]


main : Program Never Model Msg
main =
    program
        { init = ( model, Cmd.none )
        , view = invoiceView
        , subscriptions = always Sub.none
        , update = update
        }
