module Pages.StaticHttpRequest exposing (Error(..), RawRequest(..), Status(..), WhatToDo(..), cacheRequestResolution, merge, resolve, resolveUrls, strippedResponses, strippedResponsesEncode, toBuildError)

import BuildError exposing (BuildError)
import Dict exposing (Dict)
import Internal.OptimizedDecoder
import Json.Decode.Exploration
import OptimizedDecoder
import Pages.Internal.ApplicationType exposing (ApplicationType)
import Pages.StaticHttp.Request
import RequestsAndPending exposing (RequestsAndPending)
import Secrets
import TerminalText as Terminal


type RawRequest value
    = Request
        ( List (Secrets.Value Pages.StaticHttp.Request.Request)
        , ApplicationType -> RequestsAndPending -> ( Dict String WhatToDo, RawRequest value )
        )
    | RequestError Error
    | Done value


type WhatToDo
    = UseRawResponse
    | StripResponse (OptimizedDecoder.Decoder ())


merge : WhatToDo -> WhatToDo -> WhatToDo
merge whatToDo1 whatToDo2 =
    case ( whatToDo1, whatToDo2 ) of
        ( StripResponse strip1, StripResponse strip2 ) ->
            StripResponse (OptimizedDecoder.map2 (\_ _ -> ()) strip1 strip2)

        ( StripResponse strip1, _ ) ->
            StripResponse strip1

        ( _, StripResponse strip1 ) ->
            StripResponse strip1

        _ ->
            UseRawResponse


strippedResponses : ApplicationType -> RawRequest value -> RequestsAndPending -> Dict String WhatToDo
strippedResponses =
    strippedResponsesHelp Dict.empty


strippedResponsesEncode : ApplicationType -> RawRequest value -> RequestsAndPending -> Dict String String
strippedResponsesEncode appType rawRequest requestsAndPending =
    strippedResponses appType rawRequest requestsAndPending
        |> Dict.map
            (\k whatToDo ->
                case whatToDo of
                    UseRawResponse ->
                        Dict.get k requestsAndPending
                            |> Maybe.withDefault Nothing
                            |> Maybe.withDefault ""

                    StripResponse decoder ->
                        Dict.get k requestsAndPending
                            |> Maybe.withDefault Nothing
                            |> Maybe.withDefault ""
                            |> Json.Decode.Exploration.stripString (Internal.OptimizedDecoder.jde decoder)
                            |> Result.withDefault "ERROR"
            )


strippedResponsesHelp : Dict String WhatToDo -> ApplicationType -> RawRequest value -> RequestsAndPending -> Dict String WhatToDo
strippedResponsesHelp usedSoFar appType request rawResponses =
    case request of
        RequestError error ->
            usedSoFar

        Request ( _, lookupFn ) ->
            case lookupFn appType rawResponses of
                ( partiallyStrippedResponses, followupRequest ) ->
                    strippedResponsesHelp
                        (Dict.merge
                            (\key a -> Dict.insert key a)
                            (\key a b -> Dict.insert key (merge a b))
                            (\key b -> Dict.insert key b)
                            usedSoFar
                            partiallyStrippedResponses
                            Dict.empty
                        )
                        appType
                        followupRequest
                        rawResponses

        Done _ ->
            usedSoFar


type Error
    = MissingHttpResponse String
    | DecoderError String
    | UserCalledStaticHttpFail String


toBuildError : String -> Error -> BuildError
toBuildError path error =
    case error of
        MissingHttpResponse missingKey ->
            { title = "Missing Http Response"
            , message =
                [ Terminal.text missingKey
                ]
            , path = path
            , fatal = True
            }

        DecoderError decodeErrorMessage ->
            { title = "Static Http Decoding Error"
            , message =
                [ Terminal.text decodeErrorMessage
                ]
            , path = path
            , fatal = True
            }

        UserCalledStaticHttpFail decodeErrorMessage ->
            { title = "Called Static Http Fail"
            , message =
                [ Terminal.text <| "I ran into a call to `DataSource.fail` with message: " ++ decodeErrorMessage
                ]
            , path = path
            , fatal = True
            }


resolve : ApplicationType -> RawRequest value -> RequestsAndPending -> Result Error value
resolve appType request rawResponses =
    case request of
        RequestError error ->
            Err error

        Request ( _, lookupFn ) ->
            case lookupFn appType rawResponses of
                ( _, nextRequest ) ->
                    resolve appType nextRequest rawResponses

        Done value ->
            Ok value


resolveUrls : ApplicationType -> RawRequest value -> RequestsAndPending -> ( Bool, List (Secrets.Value Pages.StaticHttp.Request.Request) )
resolveUrls appType request rawResponses =
    case request of
        RequestError _ ->
            ( False
            , []
              -- TODO do I need to preserve the URLs here? -- urlList
            )

        Request ( urlList, lookupFn ) ->
            case lookupFn appType rawResponses of
                ( _, nextRequest ) ->
                    resolveUrls appType nextRequest rawResponses
                        |> Tuple.mapSecond ((++) urlList)

        Done _ ->
            ( True, [] )


cacheRequestResolution :
    ApplicationType
    -> RawRequest value
    -> RequestsAndPending
    -> Status value
cacheRequestResolution =
    cacheRequestResolutionHelp []


type Status value
    = Incomplete (List (Secrets.Value Pages.StaticHttp.Request.Request))
    | HasPermanentError Error
    | Complete


cacheRequestResolutionHelp :
    List (Secrets.Value Pages.StaticHttp.Request.Request)
    -> ApplicationType
    -> RawRequest value
    -> RequestsAndPending
    -> Status value
cacheRequestResolutionHelp foundUrls appType request rawResponses =
    case request of
        RequestError error ->
            case error of
                MissingHttpResponse _ ->
                    -- TODO do I need to pass through continuation URLs here? -- Incomplete (urlList ++ foundUrls)
                    Incomplete foundUrls

                DecoderError _ ->
                    HasPermanentError error

                UserCalledStaticHttpFail _ ->
                    HasPermanentError error

        Request ( urlList, lookupFn ) ->
            case lookupFn appType rawResponses of
                ( _, nextRequest ) ->
                    cacheRequestResolutionHelp urlList appType nextRequest rawResponses

        Done _ ->
            Complete
