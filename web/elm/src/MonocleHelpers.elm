module MonocleHelpers exposing (modifyWithEffect)

import Maybe.Extra
import Monocle.Lens
import Monocle.Optional


(=|>) : Monocle.Optional.Optional a b -> Monocle.Lens.Lens b c -> Monocle.Optional.Optional a c
(=|>) =
    Monocle.Optional.composeLens


(<|=) : Monocle.Lens.Lens a b -> Monocle.Optional.Optional b c -> Monocle.Optional.Optional a c
(<|=) =
    Monocle.Optional.compose << Monocle.Optional.fromLens



-- bind, like in Haskell


(>>=) : Monocle.Optional.Optional a b -> (b -> Monocle.Optional.Optional a c) -> Monocle.Optional.Optional a c
(>>=) opt f =
    { getOption = \a -> opt.getOption a |> Maybe.map (\b -> (f b).getOption a) |> Maybe.Extra.join
    , set = \c a -> opt.getOption a |> Maybe.map (\b -> (f b).set c a) |> Maybe.withDefault a
    }


modifyWithEffect : Monocle.Optional.Optional a b -> (b -> ( b, Cmd msg )) -> a -> ( a, Cmd msg )
modifyWithEffect l f m =
    l.getOption m |> Maybe.map f |> Maybe.map (Tuple.mapFirst (\a -> l.set a m)) |> Maybe.withDefault ( m, Cmd.none )
