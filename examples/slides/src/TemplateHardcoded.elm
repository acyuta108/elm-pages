module TemplateHardcoded exposing (..)

import Head
import Pages
import Pages.PagePath exposing (PagePath)
import Pages.StaticHttp as StaticHttp
import TemplateType


template :
    { staticData :
        List ( PagePath, TemplateType.Metadata )
        -> StaticHttp.Request staticData
    , view :
        List ( PagePath, TemplateType.Metadata )
        -> staticData
        -> model
        -> metadata
        -> renderedTemplate
        -> view
    , head :
        staticData
        -> PagePath
        -> metadata
        -> List (Head.Tag Pages.PathKey)
    , init : metadata -> ( model, Cmd templateMsg )
    , update : metadata -> templateMsg -> model -> ( model, Cmd templateMsg )
    }
    -> Template metadata renderedTemplate staticData model view templateMsg
template config =
    config


type alias Template metadata renderedTemplate staticData model view templateMsg =
    { staticData :
        List ( PagePath, TemplateType.Metadata )
        -> StaticHttp.Request staticData
    , view :
        List ( PagePath, TemplateType.Metadata )
        -> staticData
        -> model
        -> metadata
        -> renderedTemplate
        -> view
    , head :
        staticData
        -> PagePath
        -> metadata
        -> List (Head.Tag Pages.PathKey)
    , init : metadata -> ( model, Cmd templateMsg )
    , update : metadata -> templateMsg -> model -> ( model, Cmd templateMsg )
    }