module Html.Styled.Lazy exposing (lazy, lazy2, lazy3)

{-| Drop-in replacement for the `Html.Lazy` module from the `elm-lang/html` package.

@docs lazy, lazy2, lazy3

-}

import Html.Styled as Html exposing (Html)
import Html.Styled.Internal exposing (StyledHtml(Unstyled))
import VirtualDom exposing (Node)


{-| A performance optimization that delays the building of virtual DOM nodes.
Calling `(view model)` will definitely build some virtual DOM, perhaps a lot of
it. Calling `(lazy view model)` delays the call until later. During diffing, we
can check to see if `model` is referentially equal to the previous value used,
and if so, we just stop. No need to build up the tree structure and diff it,
we know if the input to `view` is the same, the output must be the same!
-}
lazy : (a -> Html msg) -> a -> Html msg
lazy fn arg =
    VirtualDom.lazy (Html.toUnstyled << fn) arg
        |> Unstyled


{-| Same as `lazy` but checks on two arguments.
-}
lazy2 : (a -> b -> Html msg) -> a -> b -> Html msg
lazy2 fn arg1 arg2 =
    VirtualDom.lazy2 (\a b -> Html.toUnstyled (fn a b)) arg1 arg2
        |> Unstyled


{-| Same as `lazy` but checks on three arguments.
-}
lazy3 : (a -> b -> c -> Html msg) -> a -> b -> c -> Html msg
lazy3 fn arg1 arg2 arg3 =
    VirtualDom.lazy3 (\a b c -> Html.toUnstyled (fn a b c)) arg1 arg2 arg3
        |> Unstyled
