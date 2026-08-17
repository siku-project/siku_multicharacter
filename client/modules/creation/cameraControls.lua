local PAN_SENSITIVITY <const> = 0.004
local ROTATE_SENSITIVITY <const> = 0.5
local ZOOM_STEP <const> = 0.45
local MIN_FOCUS_DISTANCE <const> = 0.8
local MAX_FOCUS_DISTANCE <const> = 8.0
local GROUND_CLEARANCE <const> = 0.75

local panning = false
local rotating = false

--- Checks that a camera position stays around the character: inside the
--- distance range, and never below the ground at their feet.
---@param position vector3 The wanted camera position.
---@return boolean allowed Whether the position is acceptable.
local function isAllowedPosition(position)
  local pedCoords <const> = GetEntityCoords(PlayerPedId())
  local distance <const> = #(position - (pedCoords + vector3(0.0, 0.0, 0.5)))

  if distance < MIN_FOCUS_DISTANCE or distance > MAX_FOCUS_DISTANCE then
    return false
  end

  return position.z >= pedCoords.z - GROUND_CLEARANCE
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
    local right <const>, _ <const>, up <const>, position <const> = GetCamMatrix(camera)
    local wanted <const> = position
      - right * (movementX * PAN_SENSITIVITY)
      + up * (movementY * PAN_SENSITIVITY)

    if isAllowedPosition(wanted) then
      Siku.camera.setCoords(camera, wanted)
    end
  elseif data.type == 'rotate' and rotating then
    local ped <const> = PlayerPedId()
    SetEntityHeading(ped, (GetEntityHeading(ped) + movementX * ROTATE_SENSITIVITY) % 360.0)
  end
end)

RegisterNUICallback('siku_multicharacter:nui:cameraZoom', function(data, cb)
  cb({})

  local camera <const> = GetCreationCamera()
  if not camera then
    return
  end

  local right <const>, forward <const>, up <const>, position <const> = GetCamMatrix(camera)
  local halfFov <const> = math.rad(Siku.camera.getFov(camera)) / 2.0
  local spread <const> = math.tan(halfFov)
  local aspect <const> = GetAspectRatio(true)

  local screenX <const> = ((data.mouseX or 0.5) - 0.5) * 2.0
  local screenY <const> = (0.5 - (data.mouseY or 0.5)) * 2.0

  local direction <const> = forward
    + right * (screenX * spread * aspect)
    + up * (screenY * spread)
  local step <const> = data.zoomIn and ZOOM_STEP or -ZOOM_STEP
  local wanted <const> = position + direction * (step / #direction)

  if isAllowedPosition(wanted) then
    Siku.camera.setCoords(camera, wanted)
  end
end)
