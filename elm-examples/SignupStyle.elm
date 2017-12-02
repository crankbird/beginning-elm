module SignupStyle exposing (..)

import Html exposing (Attribute)
import Html.Attributes exposing (style, id, type_)


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
