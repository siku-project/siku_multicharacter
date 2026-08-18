local SELECTION_MODEL <const> = 'mp_m_freemode_01'
local CAMERA_DISTANCE <const> = 2.8
local CAMERA_HEIGHT <const> = 1.6
local CAMERA_FOCUS_HEIGHT <const> = 0.6
local CAMERA_FOV <const> = 45.0

local selectionCamera = nil

--- Resets every ped clothing component and prop to its default.
---@param ped number The ped handle.
---@return nil
local function setDefaultClothes(ped)
  for i = 0, 11 do
    SetPedComponentVariation(ped, i, 0, 0, 4)
  end

  for i = 0, 7 do
    ClearPedProp(ped, i)
  end
end

--- Stages the player at the staging spot behind a black screen, then
--- shuts the loading screen down.
---@return number ped The staged ped handle.
local function stageForSelection()
  DoScreenFadeOut(500)
  Siku.WaitFor(function()
    return IsScreenFadedOut() or nil
  end, T('error_screen_never_faded'), 2000)

  local staging <const> = SpawnConfig.characterSelectionSpawn
  local modelHash <const> = Siku.RequestModel(SELECTION_MODEL)

  SetPlayerModel(PlayerId(), modelHash)
  SetModelAsNoLongerNeeded(modelHash)

  local ped <const> = PlayerPedId()

  setDefaultClothes(ped)

  SetEntityCoords(ped, staging.x, staging.y, staging.z, false, false, false, true)
  SetEntityHeading(ped, staging.w)
  FreezeEntityPosition(ped, true)
  SetEntityVisible(ped, true, false)
  SetEntityInvincible(ped, true)
  SetPlayerControl(PlayerId(), false, 0)

  ShutdownLoadingScreen()
  ShutdownLoadingScreenNui()

  return ped
end

--- Places the fixed selection camera in front of the staged character,
--- framed exactly like the one the creation scene settles on.
---@param ped number The ped handle.
---@return nil
local function placeSelectionCamera(ped)
  local staging <const> = SpawnConfig.characterSelectionSpawn
  local base <const> = vector3(staging.x, staging.y, staging.z)
  local forward <const> = GetEntityForwardVector(ped)
  local coords <const> = base + forward * CAMERA_DISTANCE + vector3(0.0, 0.0, CAMERA_HEIGHT)
  local focus <const> = base + vector3(0.0, 0.0, CAMERA_FOCUS_HEIGHT)

  selectionCamera = Siku.camera.create({
    coords = coords,
    rotation = Siku.camera.rotationTo(coords, focus),
    fov = CAMERA_FOV,
  })

  Siku.camera.render(selectionCamera)
end

--- Destroys the selection camera once the screen is over.
---@return nil
function ClearSelectionCamera()
  if not selectionCamera then
    return
  end

  Siku.camera.destroy(selectionCamera)
  selectionCamera = nil
end

RegisterNetEvent('siku_multicharacter:client:prepareCharacterSelect', function()
  local ped <const> = stageForSelection()

  placeSelectionCamera(ped)

  local ok <const>, payload = Siku.TriggerServerCallback('siku_multicharacter:callback:getCharacters')

  if not ok then
    Siku.print.error(T('error_characters_fetch_failed', tostring(payload)))
    return
  end

  SendNUIMessage({
    action = 'siku_multicharacter:nui:setCharacters',
    characters = payload.characters or {},
    config = payload.config or {},
  })

  SetNuiFocus(true, true)
  SendNUIMessage({ action = 'siku_multicharacter:nui:setScreen', screen = 'selection' })

  DoScreenFadeIn(800)

  Siku.print.debug(('Character selection opened with %d character(s)'):format(#(payload.characters or {})))
end)
