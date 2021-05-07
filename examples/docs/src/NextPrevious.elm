module NextPrevious exposing (..)

import Css
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attr exposing (css)
import Svg.Styled exposing (path, svg)
import Svg.Styled.Attributes as SvgAttr
import Tailwind.Utilities as Tw


view left right =
    div
        [ css
            [ Tw.pt_16
            ]
        ]
        [ nav
            [ css
                [ Tw.flex
                , Tw.flex_row
                , Tw.items_center
                , Tw.justify_between
                ]
            ]
            [ div []
                [ a
                    [ linkStyle
                    , Attr.title left.title
                    , Attr.href left.url
                    ]
                    [ leftArrow
                    , text left.title
                    ]
                ]
            , div []
                [ a
                    [ linkStyle
                    , Attr.title right.title
                    , Attr.href right.url
                    ]
                    [ text right.title
                    , rightArrow
                    ]
                ]
            ]
        ]


linkStyle =
    css
        [ Tw.text_lg
        , Tw.font_medium
        , Tw.p_4
        , Tw.neg_m_4
        , Tw.no_underline |> Css.important
        , Tw.text_gray_600 |> Css.important
        , Tw.flex
        , Tw.items_center
        , Tw.mr_2
        , Css.hover
            [ Tw.text_blue_600
            ]
        ]


leftArrow : Html msg
leftArrow =
    svg
        [ SvgAttr.height "24"
        , SvgAttr.fill "none"
        , SvgAttr.viewBox "0 0 24 24"
        , SvgAttr.stroke "currentColor"
        , SvgAttr.css
            [ Tw.transform
            , Tw.inline
            , Tw.flex_shrink_0
            , Tw.rotate_180
            , Tw.mr_1
            ]
        ]
        [ path
            [ SvgAttr.strokeLinecap "round"
            , SvgAttr.strokeLinejoin "round"
            , SvgAttr.strokeWidth "2"
            , SvgAttr.d "M9 5l7 7-7 7"
            ]
            []
        ]


rightArrow : Html msg
rightArrow =
    svg
        [ SvgAttr.height "24"
        , SvgAttr.fill "none"
        , SvgAttr.viewBox "0 0 24 24"
        , SvgAttr.stroke "currentColor"
        , SvgAttr.css
            [ Tw.transform
            , Tw.inline
            , Tw.flex_shrink_0
            , Tw.ml_1
            ]
        ]
        [ path
            [ SvgAttr.strokeLinecap "round"
            , SvgAttr.strokeLinejoin "round"
            , SvgAttr.strokeWidth "2"
            , SvgAttr.d "M9 5l7 7-7 7"
            ]
            []
        ]