module Post exposing (Post, fetchPosts)

import Http
import Json.Decode as Decode


type alias Post =
    { id : String
    , title : String
    , author : String
    }


decoder : Decode.Decoder Post
decoder =
    Decode.map3 Post
        (Decode.field "id" Decode.string)
        (Decode.field "title" Decode.string)
        (Decode.field "author" Decode.string)


fetchPosts : (Result Http.Error (List Post) -> msg) -> Cmd msg
fetchPosts toMsg =
    Http.get
        { url = "http://localhost:3000/posts"
        , expect = Http.expectJson toMsg (Decode.list decoder)
        }
