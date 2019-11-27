module Comment exposing (Comment, fetchComments)

import Http
import Json.Decode as Decode


type alias Comment =
    { id : String
    , body : String
    , postId : String
    }


decoder : Decode.Decoder Comment
decoder =
    Decode.map3 Comment
        (Decode.field "id" Decode.string)
        (Decode.field "body" Decode.string)
        (Decode.field "postId" Decode.string)


fetchComments : String -> (Result Http.Error (List Comment) -> msg) -> Cmd msg
fetchComments postId toMsg =
    Http.get
        { url = "http://localhost:3000/comments?postId=" ++ postId
        , expect = Http.expectJson toMsg (Decode.list decoder)
        }
