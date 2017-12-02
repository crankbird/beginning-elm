module Html.Styled.Internal
    exposing
        ( Classname
        , InternalAttribute(..)
        , StyledHtml(..)
        , classProperty
        , extractProperty
        , getClassname
        , makeSnippet
        , mapAttribute
        , unstyle
        , unstyleKeyed
        )

import Css.Preprocess as Preprocess exposing (Style)
import Css.Preprocess.Resolve as Resolve
import Css.Structure as Structure
import Dict exposing (Dict)
import Hex
import Json.Encode
import Murmur3
import VirtualDom exposing (Node, Property)


type alias Classname =
    String


type StyledHtml msg
    = Element String (List (InternalAttribute msg)) (List (StyledHtml msg))
    | KeyedElement String (List (InternalAttribute msg)) (List ( String, StyledHtml msg ))
    | Unstyled (VirtualDom.Node msg)


type InternalAttribute msg
    = InternalAttribute
        (VirtualDom.Property msg)
        (List Preprocess.Style)
        -- classname is "" whenever styles is []
        -- It would be nicer to model this with separate constructors, but the
        -- browser will JIT this better. We will instantiate a *lot* of these.
        Classname


getClassname : List Style -> Classname
getClassname styles =
    if List.isEmpty styles then
        ""
    else
        -- TODO Replace this comically inefficient implementation
        -- with crawling these union types and building up a hash along the way.
        Structure.UniversalSelectorSequence []
            |> makeSnippet styles
            |> List.singleton
            |> Preprocess.stylesheet
            |> List.singleton
            |> Resolve.compile
            |> .css
            |> Murmur3.hashString murmurSeed
            |> Hex.toString
            |> String.cons '_'


makeSnippet : List Style -> Structure.SimpleSelectorSequence -> Preprocess.Snippet
makeSnippet styles sequence =
    let
        selector =
            Structure.Selector sequence [] Nothing
    in
    [ Preprocess.StyleBlockDeclaration (Preprocess.StyleBlock selector [] styles) ]
        |> Preprocess.Snippet


murmurSeed : Int
murmurSeed =
    15739


unstyle :
    String
    -> List (InternalAttribute msg)
    -> List (StyledHtml msg)
    -> Node msg
unstyle elemType attributes children =
    let
        initialStyles =
            List.foldl accumulateStyles Dict.empty attributes

        ( childNodes, styles ) =
            List.foldl accumulateStyledHtml
                ( [], initialStyles )
                children

        styleNode =
            toStyleNode styles

        properties =
            List.map extractProperty attributes
    in
    VirtualDom.node elemType properties (styleNode :: List.reverse childNodes)


unstyleKeyed :
    String
    -> List (InternalAttribute msg)
    -> List ( String, StyledHtml msg )
    -> Node msg
unstyleKeyed elemType attributes keyedChildren =
    let
        initialStyles =
            List.foldl accumulateStyles Dict.empty attributes

        ( keyedChildNodes, styles ) =
            List.foldl accumulateKeyedStyledHtml
                ( [], initialStyles )
                keyedChildren

        keyedStyleNode =
            toKeyedStyleNode styles keyedChildNodes

        properties =
            List.map extractProperty attributes
    in
    VirtualDom.keyedNode elemType properties (keyedStyleNode :: List.reverse keyedChildNodes)



-- INTERNAL --


toKeyedStyleNode :
    Dict Classname (List Style)
    -> List ( String, a )
    -> ( String, Node msg )
toKeyedStyleNode allStyles keyedChildNodes =
    let
        styleNodeKey =
            getUnusedKey "_" keyedChildNodes

        finalNode =
            toStyleNode allStyles
    in
    ( styleNodeKey, finalNode )


toStyleNode : Dict Classname (List Style) -> Node msg
toStyleNode styles =
    -- this <style> node will be the first child of the requested one
    toDeclaration styles
        |> VirtualDom.text
        |> List.singleton
        |> VirtualDom.node "style" []



-- INTERNAL --


accumulateStyles :
    InternalAttribute msg
    -> Dict Classname (List Style)
    -> Dict Classname (List Style)
accumulateStyles (InternalAttribute property newStyles classname) styles =
    if List.isEmpty newStyles then
        styles
    else
        Dict.insert classname newStyles styles


extractProperty : InternalAttribute msg -> VirtualDom.Property msg
extractProperty (InternalAttribute val _ _) =
    val


accumulateStyledHtml :
    StyledHtml msg
    -> ( List (Node msg), Dict Classname (List Style) )
    -> ( List (Node msg), Dict Classname (List Style) )
accumulateStyledHtml html ( nodes, styles ) =
    case html of
        Unstyled vdom ->
            ( vdom :: nodes, styles )

        Element elemType attributes children ->
            let
                combinedStyles =
                    List.foldl accumulateStyles styles attributes

                ( childNodes, finalStyles ) =
                    List.foldl accumulateStyledHtml ( [], combinedStyles ) children

                vdom =
                    VirtualDom.node elemType
                        (List.map extractProperty attributes)
                        (List.reverse childNodes)
            in
            ( vdom :: nodes, finalStyles )

        KeyedElement elemType attributes children ->
            let
                combinedStyles =
                    List.foldl accumulateStyles styles attributes

                ( childNodes, finalStyles ) =
                    List.foldl accumulateKeyedStyledHtml ( [], combinedStyles ) children

                vdom =
                    VirtualDom.keyedNode elemType
                        (List.map extractProperty attributes)
                        (List.reverse childNodes)
            in
            ( vdom :: nodes, finalStyles )


accumulateKeyedStyledHtml :
    ( String, StyledHtml msg )
    -> ( List ( String, Node msg ), Dict Classname (List Style) )
    -> ( List ( String, Node msg ), Dict Classname (List Style) )
accumulateKeyedStyledHtml ( key, html ) ( pairs, styles ) =
    case html of
        Unstyled vdom ->
            ( ( key, vdom ) :: pairs, styles )

        Element elemType attributes children ->
            let
                combinedStyles =
                    List.foldl accumulateStyles styles attributes

                ( childNodes, finalStyles ) =
                    List.foldl accumulateStyledHtml ( [], combinedStyles ) children

                vdom =
                    VirtualDom.node elemType
                        (List.map extractProperty attributes)
                        (List.reverse childNodes)
            in
            ( ( key, vdom ) :: pairs, finalStyles )

        KeyedElement elemType attributes children ->
            let
                combinedStyles =
                    List.foldl accumulateStyles styles attributes

                ( childNodes, finalStyles ) =
                    List.foldl accumulateKeyedStyledHtml ( [], combinedStyles ) children

                vdom =
                    VirtualDom.keyedNode elemType
                        (List.map extractProperty attributes)
                        (List.reverse childNodes)
            in
            ( ( key, vdom ) :: pairs, finalStyles )


class : Classname -> Property msg
class =
    Json.Encode.string >> VirtualDom.property "className"


toDeclaration : Dict Classname (List Style) -> String
toDeclaration dict =
    Dict.toList dict
        |> List.map snippetFromPair
        |> Preprocess.stylesheet
        |> List.singleton
        |> Resolve.compile
        |> .css


snippetFromPair : ( Classname, List Style ) -> Preprocess.Snippet
snippetFromPair ( classname, styles ) =
    [ Structure.ClassSelector classname ]
        |> Structure.UniversalSelectorSequence
        |> makeSnippet styles


{-| returns a String key that is not already one of the keys in the list of
key-value pairs. We need this in order to prepend to a list of StyledHtml.Keyed
nodes with a guaranteed-unique key.
-}
getUnusedKey : String -> List ( String, a ) -> String
getUnusedKey default pairs =
    case pairs of
        [] ->
            default

        ( firstKey, _ ) :: rest ->
            let
                newKey =
                    "_" ++ firstKey
            in
            if containsKey newKey rest then
                getUnusedKey newKey rest
            else
                newKey


containsKey : String -> List ( String, a ) -> Bool
containsKey key pairs =
    case pairs of
        [] ->
            False

        ( str, _ ) :: rest ->
            if key == str then
                True
            else
                containsKey key rest


{-| Often used with CSS to style elements with common properties.
-}
classProperty : String -> VirtualDom.Property msg
classProperty val =
    VirtualDom.property "className" (Json.Encode.string val)


mapAttribute : (a -> b) -> InternalAttribute a -> InternalAttribute b
mapAttribute transform (InternalAttribute property styles classname) =
    InternalAttribute (VirtualDom.mapProperty transform property) styles classname
