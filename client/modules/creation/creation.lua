local identityDraft = nil
local sceneCamera = nil

local FREEMODE_GENDERS <const> = {
  mp_m_freemode_01 = 'm',
  mp_f_freemode_01 = 'f',
}

--- Swaps the player to a model and restages them at the staging spot,
--- with the configured default look when the model is a freemode one.
---@param model string The ped model name.
---@return number ped The restaged ped handle.
local function restagePlayer(model)
  local modelHash <const> = Siku.streaming.requestModel(model)

  SetPlayerModel(PlayerId(), modelHash)
  SetModelAsNoLongerNeeded(modelHash)

  local ped <const> = PlayerPedId()
  local staging <const> = SpawnConfig.characterSelectionSpawn

  SetEntityCoords(ped, staging.x, staging.y, staging.z, false, false, false, true)
  SetEntityHeading(ped, staging.w)
  FreezeEntityPosition(ped, true)
  SetPlayerControl(PlayerId(), false, 0)

  local gender <const> = FREEMODE_GENDERS[model]

  if gender then
    ApplyDefaultCharacter(ped, gender)
    SendAppearanceLimits(ped)
  end

  SendClothingLimits(ped)
  SendAccessoryLimits(ped)
  SendTattooLimits(ped)

  return ped
end

--- Plays the creation intro as a single continuous spline shot: the
--- camera dives from the sky, closes in from behind, circles the
--- character while facing them, then settles in front, slightly above.
---@param ped number The ped handle.
---@return nil
local function playIntroCamera(ped)
  local staging <const> = SpawnConfig.characterSelectionSpawn
  local base <const> = vector3(staging.x, staging.y, staging.z)
  local forward <const> = GetEntityForwardVector(ped)
  local right <const> = vector3(forward.y, -forward.x, 0.0)
  local focus <const> = base + vector3(0.0, 0.0, 0.6)

  local points <const> = {
    { coords = base - forward * 45.0 + vector3(0.0, 0.0, 60.0), duration = 0 },
    { coords = base - forward * 12.0 + vector3(0.0, 0.0, 4.0), duration = 2400 },
    { coords = base - forward * 4.5 + vector3(0.0, 0.0, 2.0), duration = 1800 },
    { coords = base + right * 3.4 + vector3(0.0, 0.0, 1.7), duration = 1600 },
    { coords = base + forward * 2.8 + vector3(0.0, 0.0, 1.6), duration = 1600 },
  }

  local nodes <const> = {}

  for i = 1, #points do
    nodes[i] = {
      coords = points[i].coords,
      rotation = Siku.camera.rotationTo(points[i].coords, focus),
      duration = points[i].duration,
    }
  end

  local splineCamera <const> = Siku.camera.createSpline({
    nodes = nodes,
    fov = 45.0,
  })

  Siku.camera.pointAtBone(splineCamera, ped, 31086)
  Siku.camera.render(splineCamera)
  DoScreenFadeIn(1000)

  local duration <const> = 7400
  local start <const> = GetGameTimer()

  while true do
    local progress <const> = (GetGameTimer() - start) / duration

    if progress >= 1.0 then
      break
    end

    Siku.camera.setSplinePhase(splineCamera, progress * progress * (3.0 - 2.0 * progress))
    Wait(0)
  end

  Siku.camera.setSplinePhase(splineCamera, 1.0)

  local coords <const>, rotation <const>, fov <const> = Siku.camera.getTransform(splineCamera)

  sceneCamera = Siku.camera.create({ coords = coords, rotation = rotation, fov = fov })
  Siku.camera.render(sceneCamera)
  Siku.camera.destroy(splineCamera)
end

--- Gets the camera used by the creation scene.
---@return number|nil camera The scene camera handle, or nil before the scene.
function GetCreationCamera()
  return sceneCamera
end

--- Forgets the creation camera once the scene is over.
---@return nil
function ClearCreationCamera()
  sceneCamera = nil
end

--- Gets the identity submitted from the creation interface.
---@return table|nil identity The identity draft, or nil before submission.
function GetIdentityDraft()
  return identityDraft
end

RegisterNUICallback('siku_multicharacter:nui:identitySubmitted', function(data, cb)
  cb({})
  identityDraft = data

  CreateThread(function()
    SendNUIMessage({ action = 'siku_multicharacter:nui:setScreen', screen = 'hidden' })
    SetNuiFocus(false, false)

    local model <const> = data.gender == 'female' and 'mp_f_freemode_01' or 'mp_m_freemode_01'
    local ped <const> = restagePlayer(model)

    playIntroCamera(ped)
    SetEntityVisible(ped, false, false)

    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'siku_multicharacter:nui:setScreen', screen = 'appearance' })
  end)
end)

RegisterNUICallback('siku_multicharacter:nui:pedSelected', function(data, cb)
  cb({})

  if type(data) ~= 'table' or type(data.model) ~= 'string' then
    return
  end

  CreateThread(function()
    local ped <const> = restagePlayer(data.model)

    SetEntityVisible(ped, true, false)

    if sceneCamera then
      Siku.camera.lookAt(sceneCamera, GetPedBoneCoords(ped, 31086, 0.0, 0.0, 0.0))
    end
  end)
end)
