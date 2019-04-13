module Triangle exposing (main)

import Browser
import Browser.Events exposing (onAnimationFrameDelta)
import Html exposing (Html, div, h2, text, span, input, br)
import Html.Attributes exposing (width, height, style, type_, value)
import WebGL exposing (Mesh, Shader)
import Math.Matrix4 as Mat4 exposing (Mat4)
import Math.Vector3 as Vec3 exposing (vec3, Vec3, getX, getY, getZ)
import Json.Decode exposing (Value)

import Html.Events exposing (onInput)

type alias Model =
    { t : Float
    , redInput : String
    , blueInput : String
    , greenInput : String
    , distanceInput : String
    }


initialModel =
    { t = 1500
    , redInput = "1.0"
    , blueInput = "0.0"
    , greenInput = "0.0"
    , distanceInput = "1.0"
    }


main : Program Value Model Msg
main =
    Browser.element
        { init = \_ -> ( initialModel, Cmd.none )
        , view = view
        , subscriptions = subscriptions
        , update = update
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ onAnimationFrameDelta SetTime
        ]


type Msg
    = SetTime Float
    | SetRed String
    | SetBlue String
    | SetGreen String
    | SetDistance String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetTime t ->
            ( { model | t = model.t + t }, Cmd.none )
        SetRed red ->
            ( { model | redInput = red }, Cmd.none )
        SetBlue blue ->
            ( { model | blueInput = blue }, Cmd.none )
        SetGreen green ->
            ( { model | greenInput = green }, Cmd.none )
        SetDistance distance ->
            ( { model | distanceInput = distance }, Cmd.none )


view : Model -> Html Msg
view model =
    let
        red = Maybe.withDefault 0 <| String.toFloat model.redInput
        blue = Maybe.withDefault 0 <| String.toFloat model.blueInput
        green = Maybe.withDefault 0 <| String.toFloat model.greenInput
        distance = Maybe.withDefault 1.0 <| String.toFloat model.distanceInput
    in
        div []
            [ WebGL.toHtml
                [ width 400
                , height 400
                , style "display" "block"
                ]
                [ WebGL.entity
                    vertexShader
                    fragmentShader
                    mesh
                    { perspective = perspective (model.t / 1000)
                    , ucolor = vec3 red green blue
                    , udistance = distance
                    }
                ]
            , configForm model
            ]

configForm : Model -> Html Msg
configForm model =
        div []
            [ h2 [] [ text "Config" ]
            , span [] [ text "Red" ]
            , input [ type_ "input"
                    , value model.redInput
                    , onInput SetRed
                    ] []
            , span [] [ text "Blue" ]
            , input [ type_ "input"
                    , value model.blueInput
                    , onInput SetBlue
                    ] []
            , span [] [ text "Green" ]
            , input [ type_ "input"
                    , value model.greenInput
                    , onInput SetGreen
                    ] []
            , br [] []
            , span [] [ text "Distance" ]
            , input [ type_ "input"
                    , value model.distanceInput
                    , onInput SetDistance
                    ] []
            ]


perspective : Float -> Mat4
perspective t =
    Mat4.mul
        (Mat4.makePerspective 45 1 0.01 100)
        (Mat4.makeLookAt (vec3 (4 * cos t) 0 (4 * sin t)) (vec3 0 0 0) (vec3 0 1 0))



-- Mesh


type alias Vertex =
    { position : Vec3
    , color : Vec3
    }


mesh : Mesh Vertex
mesh =
    WebGL.triangles
        [ ( Vertex (vec3 0 0 0) (vec3 1 0 0)
          , Vertex (vec3 1 1 0) (vec3 1 0 0)
          , Vertex (vec3 1 -1 0) (vec3 1 0 0)
          )
        ]



-- Shaders


type alias Uniforms =
    { perspective : Mat4
    , ucolor : Vec3
    , udistance : Float
    }


vertexShader : Shader Vertex Uniforms { vcolor : Vec3 }
vertexShader =
    [glsl|

        attribute vec3 position;
        attribute vec3 color;
        uniform mat4 perspective;
        uniform vec3 ucolor;
        uniform float udistance;
        varying vec3 vcolor;

        void main () {
            gl_Position = perspective * vec4(position, udistance);
            vcolor = ucolor;
        }

    |]


fragmentShader : Shader {} Uniforms { vcolor : Vec3 }
fragmentShader =
    [glsl|

        precision mediump float;
        varying vec3 vcolor;

        void main () {
            gl_FragColor = vec4(vcolor, 1.0);
        }

    |]
