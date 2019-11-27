module Main exposing (main)

import Backend exposing (Backend)
import Browser
import Comment exposing (Comment)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Event
import Http
import Post exposing (Post)



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Backend.NotAsked, Cmd.none )



-- MODEL


type alias Model =
    Backend Http.Error (List Section)


type alias Section =
    { post : Post
    , comments : Backend Http.Error (List Comment)
    }



-- UPDATE


type Msg
    = FetchPosts
    | GotPosts (Result Http.Error (List Post))
    | FetchComments String
    | GotComments String (Result Http.Error (List Comment))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchPosts ->
            ( Backend.Loading
            , Post.fetchPosts GotPosts
            )

        GotPosts (Ok posts) ->
            let
                toBasic post =
                    { post = post
                    , comments = Backend.NotAsked
                    }
            in
            ( Backend.Loaded <| List.map toBasic posts
            , Cmd.none
            )

        GotPosts (Err error) ->
            ( Backend.Failed error
            , Cmd.none
            )

        FetchComments postId ->
            let
                toLoading section =
                    if postId == section.post.id then
                        { section | comments = Backend.Loading }

                    else
                        section
            in
            ( Backend.map (List.map toLoading) model
            , Comment.fetchComments postId (GotComments postId)
            )

        GotComments postId (Ok comments) ->
            let
                updatePost section =
                    if section.post.id == postId then
                        { section | comments = Backend.Loaded comments }

                    else
                        section
            in
            ( Backend.map (List.map updatePost) model
            , Cmd.none
            )

        GotComments postId (Err error) ->
            let
                updatePost section =
                    if section.post.id == postId then
                        { section | comments = Backend.Failed error }

                    else
                        section
            in
            ( Backend.map (List.map updatePost) model
            , Cmd.none
            )



-- VIEW


view : Model -> Html Msg
view model =
    Html.main_
        [ Attr.class "mx-auto max-width-3" ]
        [ Html.h1 [] [ Html.text "Welcome to my Ramen blog! (ᵔᴥᵔ)" ]
        , viewSections model
        ]



-- VIEW BASIC


viewSections : Backend Http.Error (List Section) -> Html Msg
viewSections basic =
    case basic of
        Backend.NotAsked ->
            viewButton
                [ Event.onClick FetchPosts, Attr.class "btn-primary" ]
                [ Html.text "fetch posts" ]

        Backend.Loading ->
            viewLoading

        Backend.Failed error ->
            viewFailed error

        Backend.Loaded list ->
            Html.div [] (List.map viewSection list)


viewSection : Section -> Html Msg
viewSection section =
    Html.section
        []
        [ Html.h2 [ Attr.class "mb0" ] [ Html.text section.post.title ]
        , Html.small [ Attr.class "block mb3" ] [ Html.text section.post.author ]
        , viewComments section.post.id section.comments
        , Html.hr [] []
        ]


viewComments : String -> Backend Http.Error (List Comment) -> Html Msg
viewComments postId comments =
    case comments of
        Backend.NotAsked ->
            viewButton
                [ Event.onClick <| FetchComments postId
                , Attr.class "btn-small btn-outline h5"
                ]
                [ Html.text "view comments" ]

        Backend.Loading ->
            viewLoading

        Backend.Failed error ->
            viewFailed error

        Backend.Loaded list ->
            Html.ul [] (List.map (viewComment << .body) list)


viewComment : String -> Html Msg
viewComment comment =
    Html.li [] [ Html.text comment ]


viewLoading : Html msg
viewLoading =
    Html.p [] [ Html.text "loading..." ]


viewFailed : Http.Error -> Html msg
viewFailed error =
    Html.p [ Attr.class "red" ] [ Html.text <| Debug.toString error ]


viewButton : List (Html.Attribute msg) -> List (Html msg) -> Html msg
viewButton attrs =
    Html.button (attrs ++ [ Attr.class "btn" ])



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
