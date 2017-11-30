module RippleCarryAdder exposing (..)

import Bitwise
import Array


andGate a b =
    Bitwise.and a b


orGate a b =
    Bitwise.or a b


inverter a =
    case a of
        1 ->
            0

        0 ->
            1

        _ ->
            -1


halfAdder a b =
    let
        d =
            orGate a b

        e =
            andGate a b
                |> inverter

        sumDigit =
            andGate d e

        carryOut =
            andGate a b
    in
        { carry = carryOut
        , sum = sumDigit
        }


fullAdder a b carryIn =
    let
        firstResult =
            halfAdder b carryIn

        secondResult =
            halfAdder a firstResult.sum

        finalCarry =
            orGate firstResult.carry secondResult.carry
    in
        { carry = finalCarry
        , sum = secondResult.sum
        }


arrayToTuple array =
    let
        firstElement =
            Array.get 0 array
                |> Maybe.withDefault -1

        secondElement =
            Array.get 1 array
                |> Maybe.withDefault -1

        thirdElement =
            Array.get 2 array
                |> Maybe.withDefault -1

        fourthElement =
            Array.get 3 array
                |> Maybe.withDefault -1
    in
        ( firstElement, secondElement, thirdElement, fourthElement )


stringToInt string =
    String.toInt string
        |> Result.withDefault -1


extractDigits number =
    toString number
        |> String.padleft 4 '0'
        |> String.split ""
        |> List.map stringToInt
        |> Array.fromList
        |> arrayToTuple


rippleCarryAdder a b carryIn =
    let
        -- Extract digits
        ( a3, a2, a1, a0 ) =
            extractDigits a

        ( b3, b2, b1, b0 ) =
            extractDigits b

        -- Compute sum and carry-out
        firstResult =
            fullAdder a0 b0 carryIn

        secondResult =
            fullAdder a1 b1 firstResult.carry

        thirdResult =
            fullAdder a2 b2 secondResult.carry

        finalResult =
            fullAdder a3 b3 thirdResult.carry
    in
        { carry = finalResult.carry
        , sum3 = finalResult.sum
        , sum2 = thirdResult.sum
        , sum1 = secondResult.sum
        , sum0 = firstResult.sum
        }
