module Concourse.User exposing (fetchUser, logOut)

import Concourse
import Http
import HttpBuilder
import Task exposing (Task)


fetchUser : Task Http.Error Concourse.User
fetchUser =
    HttpBuilder.get "/sky/userinfo"
        |> HttpBuilder.withExpect (Http.expectJson Concourse.decodeUser)
        |> HttpBuilder.toTask


logOut : Task Http.Error ()
logOut =
    HttpBuilder.get "/sky/logout"
        |> HttpBuilder.withExpect (Http.expectStringResponse (\_ -> Ok ()))
        |> HttpBuilder.toTask
