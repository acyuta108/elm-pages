module Showcase exposing (..)

import DataSource
import DataSource.Http
import OptimizedDecoder as Decode
import Pages.Secrets as Secrets


type alias Entry =
    { screenshotUrl : String
    , displayName : String
    , liveUrl : String
    , authorName : String
    , authorUrl : String
    , categories : List String
    , repoUrl : Maybe String
    }


decoder : Decode.Decoder (List Entry)
decoder =
    Decode.field "records" <|
        Decode.list entryDecoder


entryDecoder : Decode.Decoder Entry
entryDecoder =
    Decode.field "fields" <|
        Decode.map7 Entry
            (Decode.field "Screenshot URL" Decode.string)
            (Decode.field "Site Display Name" Decode.string)
            (Decode.field "Live URL" Decode.string)
            (Decode.field "Author" Decode.string)
            (Decode.field "Author URL" Decode.string)
            (Decode.optionalField "Categories" (Decode.list Decode.string) |> Decode.map (Maybe.withDefault []))
            (Decode.maybe (Decode.field "Repository URL" Decode.string))


staticRequest : DataSource.DataSource (List Entry)
staticRequest =
    DataSource.Http.request
        (Secrets.succeed
            (\airtableToken ->
                { url = "https://api.airtable.com/v0/appDykQzbkQJAidjt/elm-pages%20showcase?maxRecords=100&view=Grid%202"
                , method = "GET"
                , headers = [ ( "Authorization", "Bearer " ++ airtableToken ), ( "view", "viwayJBsr63qRd7q3" ) ]
                , body = DataSource.Http.emptyBody
                }
            )
            |> Secrets.with "AIRTABLE_TOKEN"
        )
        decoder


allCategroies : List String
allCategroies =
    [ "Documentation"
    , "eCommerce"
    , "Conference"
    , "Consulting"
    , "Education"
    , "Entertainment"
    , "Event"
    , "Food"
    , "Freelance"
    , "Gallery"
    , "Landing Page"
    , "Music"
    , "Nonprofit"
    , "Podcast"
    , "Portfolio"
    , "Programming"
    , "Sports"
    , "Travel"
    , "Blog"
    ]
