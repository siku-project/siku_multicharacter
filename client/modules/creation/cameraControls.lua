local ORBIT_SENSITIVITY <const> = 0.008
local HEIGHT_SENSITIVITY <const> = 0.004
local ROTATE_SENSITIVITY <const> = 0.5
local ZOOM_STEP <const> = 0.45
local MIN_FOCUS_DISTANCE <const> = 0.8
local MAX_FOCUS_DISTANCE <const> = 8.0
local MIN_FOCUS_HEIGHT <const> = -0.5
local MAX_FOCUS_HEIGHT <const> = 2.2
local HEAD_BONE <const> = 31086

local panning = false
local rotating = false

--- Gets the point the creation camera revolves around.
---@return vector3 focus The head position of the player ped.
local function getFocus()
  return GetPedBoneCoords(PlayerPedId(), HEAD_BONE, 0.0, 0.0, 0.0)
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
    local focus <const> = getFocus()
    local offset <const> = Siku.camera.getCoords(camera) - focus
    local horizontal <const> = math.sqrt(offset.x * offset.x + offset.y * offset.y)
    local angle <const> = math.atan(offset.y, offset.x) + movementX * ORBIT_SENSITIVITY
    local height <const> = math.min(math.max(offset.z + movementY * HEIGHT_SENSITIVITY, MIN_FOCUS_HEIGHT), MAX_FOCUS_HEIGHT)

    Siku.camera.setCoords(camera, focus + vector3(
      math.cos(angle) * horizontal,
      math.sin(angle) * horizontal,
      height
    ))
    Siku.camera.lookAt(camera, focus)
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

  local distance <const> = #(wanted - getFocus())

  if distance < MIN_FOCUS_DISTANCE or distance > MAX_FOCUS_DISTANCE then
    return
  end

  Siku.camera.setCoords(camera, wanted)
end)
