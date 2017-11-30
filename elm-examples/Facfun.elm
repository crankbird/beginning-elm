module Facfun exposing (..)


facfun n =
    if n == 0 then
        1
    else
        n * facfun (n - 1)


sumfun i n =
    if i == n then
        n
    else
        i + sumfun (i + 1) n


fib n =
    if n == 0 then
        1
    else if n == 1 then
        1
    else
        fib (n - 1) + n
