module Concourse.Resource exposing
    ( disableVersionedResource
    , enableVersionedResource
    , fetchAllResources
    , fetchCausality
    , fetchInputTo
    , fetchOutputOf
    , fetchResource
    , fetchResourcesRaw
    , fetchVersionedResource
    , fetchVersionedResources
    , pause
    , unpause
    )

import Concourse
import Concourse.Pagination exposing (Page, Paginated, Pagination)
import Http
import Json.Decode
import Task exposing (Task)


fetchAllResources : Task Http.Error (Maybe (List Concourse.Resource))
fetchAllResources =
    Http.toTask <|
        Http.get "/api/v1/resources" (Json.Decode.nullable <| Json.Decode.list Concourse.decodeResource)


fetchResource : Concourse.ResourceIdentifier -> Task Http.Error Concourse.Resource
fetchResource rid =
    Http.toTask
        << (\a -> Http.get a Concourse.decodeResource)
    <|
        "/api/v1/teams/"
            ++ rid.teamName
            ++ "/pipelines/"
            ++ rid.pipelineName
            ++ "/resources/"
            ++ rid.resourceName


fetchResourcesRaw : Concourse.PipelineIdentifier -> Task Http.Error Json.Decode.Value
fetchResourcesRaw pi =
    Http.toTask <|
        Http.get ("/api/v1/teams/" ++ pi.teamName ++ "/pipelines/" ++ pi.pipelineName ++ "/resources") Json.Decode.value


pause : Concourse.ResourceIdentifier -> Concourse.CSRFToken -> Task Http.Error ()
pause =
    pauseUnpause True


unpause : Concourse.ResourceIdentifier -> Concourse.CSRFToken -> Task Http.Error ()
unpause =
    pauseUnpause False


pauseUnpause : Bool -> Concourse.ResourceIdentifier -> Concourse.CSRFToken -> Task Http.Error ()
pauseUnpause pause rid csrfToken =
    let
        action =
            if pause then
                "pause"

            else
                "unpause"
    in
    Http.toTask <|
        Http.request
            { method = "PUT"
            , url = "/api/v1/teams/" ++ rid.teamName ++ "/pipelines/" ++ rid.pipelineName ++ "/resources/" ++ rid.resourceName ++ "/" ++ action
            , headers = [ Http.header Concourse.csrfTokenHeaderName csrfToken ]
            , body = Http.emptyBody
            , expect = Http.expectStringResponse (\_ -> Ok ())
            , timeout = Nothing
            , withCredentials = False
            }


fetchVersionedResource : Concourse.VersionedResourceIdentifier -> Task Http.Error Concourse.VersionedResource
fetchVersionedResource vrid =
    Http.toTask
        << (\a -> Http.get a Concourse.decodeVersionedResource)
    <|
        "/api/v1/teams/"
            ++ vrid.teamName
            ++ "/pipelines/"
            ++ vrid.pipelineName
            ++ "/resources/"
            ++ vrid.resourceName
            ++ "/versions/"
            ++ toString vrid.versionID


fetchVersionedResources : Concourse.ResourceIdentifier -> Maybe Page -> Task Http.Error (Paginated Concourse.VersionedResource)
fetchVersionedResources rid page =
    let
        url =
            "/api/v1/teams/" ++ rid.teamName ++ "/pipelines/" ++ rid.pipelineName ++ "/resources/" ++ rid.resourceName ++ "/versions"
    in
    Concourse.Pagination.fetch Concourse.decodeVersionedResource url page


enableVersionedResource : Concourse.VersionedResourceIdentifier -> Concourse.CSRFToken -> Task Http.Error ()
enableVersionedResource =
    enableDisableVersionedResource True


disableVersionedResource : Concourse.VersionedResourceIdentifier -> Concourse.CSRFToken -> Task Http.Error ()
disableVersionedResource =
    enableDisableVersionedResource False


enableDisableVersionedResource : Bool -> Concourse.VersionedResourceIdentifier -> Concourse.CSRFToken -> Task Http.Error ()
enableDisableVersionedResource enable vrid csrfToken =
    let
        action =
            if enable then
                "enable"

            else
                "disable"
    in
    Http.toTask <|
        Http.request
            { method = "PUT"
            , url = "/api/v1/teams/" ++ vrid.teamName ++ "/pipelines/" ++ vrid.pipelineName ++ "/resources/" ++ vrid.resourceName ++ "/versions/" ++ toString vrid.versionID ++ "/" ++ action
            , headers = [ Http.header Concourse.csrfTokenHeaderName csrfToken ]
            , body = Http.emptyBody
            , expect = Http.expectStringResponse (\_ -> Ok ())
            , timeout = Nothing
            , withCredentials = False
            }


fetchInputTo : Concourse.VersionedResourceIdentifier -> Task Http.Error (List Concourse.Build)
fetchInputTo =
    fetchInputOutput "input_to"


fetchOutputOf : Concourse.VersionedResourceIdentifier -> Task Http.Error (List Concourse.Build)
fetchOutputOf =
    fetchInputOutput "output_of"


fetchInputOutput : String -> Concourse.VersionedResourceIdentifier -> Task Http.Error (List Concourse.Build)
fetchInputOutput action vrid =
    Http.toTask
        << (\a -> Http.get a (Json.Decode.list Concourse.decodeBuild))
    <|
        "/api/v1/teams/"
            ++ vrid.teamName
            ++ "/pipelines/"
            ++ vrid.pipelineName
            ++ "/resources/"
            ++ vrid.resourceName
            ++ "/versions/"
            ++ toString vrid.versionID
            ++ "/"
            ++ action


fetchCausality : Concourse.VersionedResourceIdentifier -> Task Http.Error (List Concourse.Cause)
fetchCausality vrid =
    Http.toTask <|
        (\a -> Http.get a (Json.Decode.list Concourse.decodeCause)) <|
            "/api/v1/teams/"
                ++ vrid.teamName
                ++ "/pipelines/"
                ++ vrid.pipelineName
                ++ "/resources/"
                ++ vrid.resourceName
                ++ "/versions/"
                ++ toString vrid.versionID
                ++ "/causality"
