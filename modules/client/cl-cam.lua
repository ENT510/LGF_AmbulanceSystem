local Cam = {}
local camera

function Cam.StartCamera(vehicle, distance, height, pointEntity, offset)
    offset = offset or 0.0
    local camCoords = GetOffsetFromEntityInWorldCoords(vehicle, offset, distance, height)
    local newCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(newCam, camCoords.x, camCoords.y, camCoords.z)

    pointEntity = pointEntity or false


    local camRotation = GetEntityHeading(vehicle) + 180

    local coords = GetCamCoord(newCam)
    SetCamFov(newCam, 38.0)

    if Cam.ExistCam() then
        local transitionDuration = 1000
        SetCamActiveWithInterp(newCam, camera, transitionDuration, 1, 1)
        Wait(transitionDuration)
        DestroyCam(camera, false)
    else
        SetCamActive(newCam, true)
    end

    camera = newCam
    RenderScriptCams(true, true, 400, 1, 0)
    if pointEntity then
        PointCamAtPedBone(newCam, vehicle, 31086, 0.0, 0.0, 0.2, true)
    end
    SetFocusEntity(vehicle)
    SetFocusArea(coords.x, coords.y, coords.z, 1.0, 1.0)


    ClearFocus()
end

function Cam.DestroyCamera()
    if camera then
        RenderScriptCams(false, true, 400, 1, 0)
        DestroyCam(camera, false)
        ClearTimecycleModifier()
        camera = nil
    end
end

function Cam.ExistCam()
    return camera ~= nil
end

return Cam
