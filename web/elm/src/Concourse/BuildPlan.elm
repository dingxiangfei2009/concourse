module Concourse.BuildPlan exposing (fetch)

import Concourse
import Http
import Task exposing (Task)


fetch : Concourse.BuildId -> Task Http.Error Concourse.BuildPlan
fetch buildId =
    Http.toTask
        << (\a -> Http.get a Concourse.decodeBuildPlan)
    <|
        "/api/v1/builds/"
            ++ toString buildId
            ++ "/plan"
