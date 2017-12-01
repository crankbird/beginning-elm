module Counter exposing (..)

import Html exposing (..)


type alias Model =
    Int


initialModel : Model
initialModel =
    0


main =
    beginnerProgram
        { model = initialModel
        , view = view
        , update = update
        }


update : msg -> Model -> Model
update msg model =
    initialModel


view : Model -> Html msg
view model =
    div []
        [ button [] [ text "-" ]
        , text (toString (model))
        , button [] [ text "+" ]
        ]
