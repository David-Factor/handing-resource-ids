module Tagged exposing (Tagged, decoder, encoder, toString, urlParser)

import Json.Decode as Decode
import Json.Encode as Encode
import Url.Parser as Parser exposing (Parser)


type Tagged tag
    = Tagged String


toString : Tagged tag -> String
toString (Tagged value) =
    value


decoder : Decode.Decoder (Tagged a)
decoder =
    Decode.map Tagged Decode.string


encoder : Tagged tag -> Encode.Value
encoder (Tagged v) =
    Encode.string v


urlParser : Parser (Tagged tag -> a) a
urlParser =
    Parser.map Tagged Parser.string
