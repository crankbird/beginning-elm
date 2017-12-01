module Counter exposing (..)

import Html exposing (..)
import Html.Events exposing (..)


type alias Model =
    Int


type Msg
    = Increment
    | Decrement


initialModel : Model
initialModel =
    0


main : Program Never Model Msg
main =
    beginnerProgram
        { model = initialModel
        , view = view
        , update = update
        }


update : Msg -> Model -> Model
update msg model =
    case msg of
        Decrement ->
            model - 1

        Increment ->
            model + 1


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick Decrement ] [ text "-" ]
        , text (toString model)
        , button [ onClick Increment ] [ text "+" ]
        ]
