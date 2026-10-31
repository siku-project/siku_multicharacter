Camera = {}

local HEAD_BONE <const> = 31086
local FOV <const> = 45.0

local SELECTION <const> = { distance = 3.2, height = 1.45, focusHeight = 1.05 }
local INTRO_DURATION <const> = 7400

local PAN_SENSITIVITY <const> = 0.004
local ROTATE_SENSITIVITY <const> = 0.5
local ZOOM_STEP <const> = 0.45
local MIN_DISTANCE <const> = 0.8
local MAX_PAN_DISTANCE <const> = 3.5
local MAX_ZOOM_DISTANCE <const> = 8.0
local GROUND_CLEARANCE <const> = 0.75

local selectionCamera = nil
local sceneCamera = nil
local panning = false
local rotating = false

local function base()
  local spot <const> = SpawnConfig.staging

  return vector3(spot.x, spot.y, spot.z)
end

---@param ped number The staged ped handle.
function Camera.placeSelection(ped)
  Camera.clearSelection()

  local forward <const> = GetEntityForwardVector(ped)
  local coords <const> = base() + forward * SELECTION.distance + vector3(0.0, 0.0, SELECTION.height)
  local focus <const> = base() + vector3(0.0, 0.0, SELECTION.focusHeight)

  selectionCamera = Siku.camera.create({
    coords = coords,
    rotation = Siku.camera.rotationTo(coords, focus),
    fov = FOV,
  })

  Siku.camera.render(selectionCamera)
end

function Camera.clearSelection()
  if selectionCamera then
    Siku.camera.destroy(selectionCamera)
    selectionCamera = nil
  end
end

---@param ped number The staged ped handle.
function Camera.playIntro(ped)
  Camera.clearScene()

  local origin <const> = base()
  local forward <const> = GetEntityForwardVector(ped)
  local right <const> = vector3(forward.y, -forward.x, 0.0)
  local focus <const> = origin + vector3(0.0, 0.0, 0.6)

  local points <const> = {
    { coords = origin - forward * 45.0 + vector3(0.0, 0.0, 60.0), duration = 0 },
    { coords = origin - forward * 12.0 + vector3(0.0, 0.0, 4.0), duration = 2400 },
    { coords = origin - forward * 4.5 + vector3(0.0, 0.0, 2.0), duration = 1800 },
    { coords = origin + right * 3.4 + vector3(0.0, 0.0, 1.7), duration = 1600 },
    { coords = origin + forward * 2.8 + vector3(0.0, 0.0, 1.6), duration = 1600 },
  }

  local nodes <const> = {}

  for i = 1, #points do
    nodes[i] = {
      coords = points[i].coords,
      rotation = Siku.camera.rotationTo(points[i].coords, focus),
      duration = points[i].duration,
    }
  end

  local spline <const> = Siku.camera.createSpline({ nodes = nodes, fov = FOV })

  Siku.camera.pointAtBone(spline, ped, HEAD_BONE)
  Siku.camera.render(spline)
  DoScreenFadeIn(1000)

  local start <const> = GetGameTimer()

  while true do
    local progress <const> = (GetGameTimer() - start) / INTRO_DURATION

    if progress >= 1.0 then
      break
    end

    Siku.camera.setSplinePhase(spline, progress * progress * (3.0 - 2.0 * progress))
    Wait(0)
  end

  Siku.camera.setSplinePhase(spline, 1.0)

  local coords <const>, rotation <const>, fov <const> = Siku.camera.getTransform(spline)

  sceneCamera = Siku.camera.create({ coords = coords, rotation = rotation, fov = fov })
  Siku.camera.render(sceneCamera)
  Siku.camera.destroy(spline)
end

---@param ped number The staged ped handle.
function Camera.focusScene(ped)
  if sceneCamera then
    Siku.camera.lookAt(sceneCamera, GetPedBoneCoords(ped, HEAD_BONE, 0.0, 0.0, 0.0))
  end
end

function Camera.clearScene()
  if sceneCamera then
    Siku.camera.destroy(sceneCamera)
    sceneCamera = nil
  end

  panning = false
  rotating = false
end

function Camera.clear()
  Camera.clearSelection()
  Camera.clearScene()
end

---@param position vector3 The wanted camera position.
---@param maxDistance number
---@return boolean allowed Inside the distance range and never below the feet.
local function allowed(position, maxDistance)
  local pedCoords <const> = GetEntityCoords(PlayerPedId())
  local distance <const> = #(position - (pedCoords + vector3(0.0, 0.0, 0.5)))

  if distance < MIN_DISTANCE or distance > maxDistance then
    return false
  end

  return position.z >= pedCoords.z - GROUND_CLEARANCE
end

Nui.on('cameraControlStart', function(data)
  if data.type == 'pan' then
    panning = true
  elseif data.type == 'rotate' then
    rotating = true
  end
end)

Nui.on('cameraControlStop', function(data)
  if data.type == 'pan' then
    panning = false
  elseif data.type == 'rotate' then
    rotating = false
  end
end)

Nui.on('cameraControlMove', function(data)
  if not sceneCamera then
    return
  end

  local movementX <const> = data.movementX or 0
  local movementY <const> = data.movementY or 0

  if data.type == 'pan' and panning then
    local right <const>, _ <const>, up <const>, position <const> = GetCamMatrix(sceneCamera)
    local wanted <const> = position - right * (movementX * PAN_SENSITIVITY) + up * (movementY * PAN_SENSITIVITY)

    if allowed(wanted, MAX_PAN_DISTANCE) then
      Siku.camera.setCoords(sceneCamera, wanted)
    end
  elseif data.type == 'rotate' and rotating then
    local ped <const> = PlayerPedId()

    SetEntityHeading(ped, (GetEntityHeading(ped) + movementX * ROTATE_SENSITIVITY) % 360.0)
  end
end)

Nui.on('cameraZoom', function(data)
  if not sceneCamera then
    return
  end

  local right <const>, forward <const>, up <const>, position <const> = GetCamMatrix(sceneCamera)
  local spread <const> = math.tan(math.rad(Siku.camera.getFov(sceneCamera)) / 2.0)
  local aspect <const> = GetAspectRatio(true)
  local screenX <const> = ((data.mouseX or 0.5) - 0.5) * 2.0
  local screenY <const> = (0.5 - (data.mouseY or 0.5)) * 2.0
  local direction <const> = forward + right * (screenX * spread * aspect) + up * (screenY * spread)
  local step <const> = data.zoomIn and ZOOM_STEP or -ZOOM_STEP
  local wanted <const> = position + direction * (step / #direction)

  if allowed(wanted, MAX_ZOOM_DISTANCE) then
    Siku.camera.setCoords(sceneCamera, wanted)
  end
end)
