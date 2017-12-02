module Signup exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import SignupStyles exposing (..)


type alias User =
    { name : String
    , email : String
    , password : String
    , loggedIn : Bool
    }


initialModel : User
initialModel =
    { name = ""
    , email = ""
    , password = ""
    , loggedIn = False
    }


view : User -> Html msg
view user =
    div []
        [ h1 [ headerStyle ] [ text "Sign up" ]
        , Html.form [ formStyle ]
            [ div []
                [ text "Name"
                , input
                    [ id "name"
                    , type_ "text"
                    , inputTextStyle
                    ]
                    []
                ]
            , div []
                [ text "Email"
                , input
                    [ id "email"
                    , type_ "email"
                    , inputTextStyle
                    ]
                    []
                ]
            , div []
                [ text "Password"
                , input
                    [ id "password"
                    , type_ "password"
                    , inputTextStyle
                    ]
                    []
                ]
            , div []
                [ button
                    [ type_ "submit"
                    , buttonStyle
                    ]
                    [ text "Create my account" ]
                ]
            ]
        ]


update : msg -> User -> User
update msg model =
    initialModel


main : Program Never User msg
main =
    beginnerProgram
        { model = initialModel
        , view = view
        , update = update
        }
