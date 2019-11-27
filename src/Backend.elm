module Backend exposing (Backend(..), map)


type Backend x a
    = NotAsked
    | Loading
    | Failed x
    | Loaded a


map : (a -> b) -> Backend x a -> Backend x b
map f backend =
    case backend of
        NotAsked ->
            NotAsked

        Loading ->
            Loading

        Failed x ->
            Failed x

        Loaded a ->
            Loaded (f a)
