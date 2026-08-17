local PAN_SENSITIVITY <const> = 0.004
local ROTATE_SENSITIVITY <const> = 0.5
local ZOOM_STEP <const> = 0.45
local MIN_FOCUS_DISTANCE <const> = 0.8
local MAX_FOCUS_DISTANCE <const> = 8.0
local HEAD_BONE <const> = 31086

local panning = false
local rotating = false

--- Moves the creation camera, refusing positions that leave the allowed
--- range around the character so the view never clips through them nor
--- drifts away from the scene.
---@param camera number The camera handle.
---@param position vector3 The wanted camera position.
---@return nil
local function moveWithinRange(camera, position)
  local focus <const> = GetPedBoneCoords(PlayerPedId(), HEAD_BONE, 0.0, 0.0, 0.0)
  local distance <const> = #(position - focus)

  if distance < MIN_FOCUS_DISTANCE or distance > MAX_FOCUS_DISTANCE then
    return
  end

  Siku.camera.setCoords(camera, position)
end

RegisterNUICallback('siku_multicharacter:nui:cameraControlStart', function(data, cb)
  cb({})

  if data.type == 'pan' then
    panning = true
  elseif data.type == 'rotate' then
    rotating = true
  end
end)

RegisterNUICallback('siku_multicharacter:nui:cameraControlStop', function(data, cb)
  cb({})

  if data.type == 'pan' then
    panning = false
  elseif data.type == 'rotate' then
    rotating = false
  end
end)

RegisterNUICallback('siku_multicharacter:nui:cameraControlMove', function(data, cb)
  cb({})

  local camera <const> = GetCreationCamera()
  if not camera then
    return
  end

  local movementX <const> = data.movementX or 0
  local movementY <const> = data.movementY or 0

  if data.type == 'pan' and panning then
    local coords <const> = Siku.camera.getCoords(camera)
    local rotation <const> = Siku.camera.getRotation(camera)
    local heading <const> = math.rad(rotation.z)

    moveWithinRange(camera, vector3(
      coords.x - math.cos(heading) * movementX * PAN_SENSITIVITY,
      coords.y - math.sin(heading) * movementX * PAN_SENSITIVITY,
      coords.z + movementY * PAN_SENSITIVITY
    ))
  elseif data.type == 'rotate' and rotating then
    local ped <const> = PlayerPedId()
    SetEntityHeading(ped, (GetEntityHeading(ped) - movementX * ROTATE_SENSITIVITY) % 360.0)
  end
end)

RegisterNUICallback('siku_multicharacter:nui:cameraZoom', function(data, cb)
  cb({})

  local camera <const> = GetCreationCamera()
  if not camera then
    return
  end

  local coords <const> = Siku.camera.getCoords(camera)
  local rotation <const> = Siku.camera.getRotation(camera)
  local pitch <const> = math.rad(rotation.x)
  local yaw <const> = math.rad(rotation.z)

  local forward <const> = vector3(
    -math.sin(yaw) * math.cos(pitch),
    math.cos(yaw) * math.cos(pitch),
    math.sin(pitch)
  )
  local right <const> = vector3(math.cos(yaw), math.sin(yaw), 0.0)

  local towardMouseX <const> = ((data.mouseX or 0.5) - 0.5) * 0.8
  local towardMouseY <const> = ((data.mouseY or 0.5) - 0.5) * -0.6
  local direction <const> = forward + right * towardMouseX + vector3(0.0, 0.0, towardMouseY)
  local step <const> = data.zoomIn and ZOOM_STEP or -ZOOM_STEP

  moveWithinRange(camera, coords + direction * (step / #direction))
end)
