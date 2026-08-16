local identityDraft = nil
local sceneCamera = nil

--- Swaps the player to the freemode model matching the chosen gender and
--- restages them with the configured default look.
---@param gender string 'm' for male, 'f' for female.
---@return number ped The restaged ped handle.
local function stageDefaultCharacter(gender)
  local model <const> = gender == 'f' and 'mp_f_freemode_01' or 'mp_m_freemode_01'
  local modelHash <const> = Siku.RequestModel(model)

  SetPlayerModel(PlayerId(), modelHash)
  SetModelAsNoLongerNeeded(modelHash)

  local ped <const> = PlayerPedId()
  local staging <const> = SpawnConfig.characterSelectionSpawn

  SetEntityCoords(ped, staging.x, staging.y, staging.z, false, false, false, true)
  SetEntityHeading(ped, staging.w)
  FreezeEntityPosition(ped, true)
  SetPlayerControl(PlayerId(), false, 0)

  ApplyDefaultCharacter(ped, gender)

  return ped
end

--- Plays the creation intro: the camera dives from the sky, closes in
--- from behind, circles the character while facing them, then settles a
--- few meters in front.
---@param ped number The ped handle.
---@return nil
local function playIntroCamera(ped)
  local staging <const> = SpawnConfig.characterSelectionSpawn
  local base <const> = vector3(staging.x, staging.y, staging.z)
  local radians <const> = math.rad(staging.w)
  local forward <const> = vector3(-math.sin(radians), math.cos(radians), 0.0)
  local right <const> = vector3(math.cos(radians), math.sin(radians), 0.0)

  sceneCamera = Siku.camera.create({
    coords = base - forward * 45.0 + vector3(0.0, 0.0, 60.0),
    fov = 45.0,
  })

  Siku.camera.pointAtBone(sceneCamera, ped, 31086)
  Siku.camera.render(sceneCamera)
  DoScreenFadeIn(1000)

  Siku.camera.moveTo(sceneCamera, { coords = base - forward * 12.0 + vector3(0.0, 0.0, 4.0) }, 2200, 'easeIn')
  Wait(2200)

  Siku.camera.moveTo(sceneCamera, { coords = base - forward * 4.0 + vector3(0.0, 0.0, 1.4) }, 1600, 'easeOut')
  Wait(1600)

  Siku.camera.moveTo(sceneCamera, { coords = base + right * 3.2 + vector3(0.0, 0.0, 0.9) }, 1400, 'linear')
  Wait(1400)

  Siku.camera.moveTo(sceneCamera, { coords = base + forward * 2.6 + vector3(0.0, 0.0, 0.7) }, 1500, 'easeOut')
  Wait(1500)
end

--- Gets the camera used by the creation scene.
---@return number|nil camera The scene camera handle, or nil before the scene.
function GetCreationCamera()
  return sceneCamera
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

    local gender <const> = data.gender == 'female' and 'f' or 'm'
    local ped <const> = stageDefaultCharacter(gender)

    playIntroCamera(ped)

    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'siku_multicharacter:nui:setScreen', screen = 'appearance' })
  end)
end)
