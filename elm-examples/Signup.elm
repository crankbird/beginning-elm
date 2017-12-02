module Signup exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)


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


headerStyle : Attribute msg
headerStyle =
    style
        [ ( "padding-left", "3cm" ) ]


formStyle : Attribute msg
formStyle =
    style
        [ ( "border-radius", "5px" )
        , ( "background-color", "#f2f2f2" )
        , ( "padding", "20px" )
        , ( "width", "300px" )
        ]


inputTextStyle : Attribute msg
inputTextStyle =
    style
        [ ( "display", "block" )
        , ( "width", "260px" )
        , ( "padding", "12px 20px" )
        , ( "margin", "8px 0" )
        , ( "border", "none" )
        , ( "border-radius", "4px" )
        ]


buttonStyle : Attribute msg
buttonStyle =
    style
        [ ( "width", "300px" )
        , ( "background-color", "#397cd5" )
        , ( "color", "white" )
        , ( "padding", "14px 20px" )
        , ( "margin-top", "10px" )
        , ( "border", "none" )
        , ( "border-radius", "4px" )
        , ( "font-size", "16px" )
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
