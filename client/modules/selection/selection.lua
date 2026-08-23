local SELECTION_MODEL <const> = 'mp_m_freemode_01'
local CAMERA_DISTANCE <const> = 3.2
local CAMERA_HEIGHT <const> = 1.45
local CAMERA_FOCUS_HEIGHT <const> = 1.05
local CAMERA_FOV <const> = 45.0

local selectionCamera = nil
local looks = {}

--- Stages the player at the staging spot behind a black screen, then
--- shuts the loading screen down.
---@return number ped The staged ped handle.
local function stageForSelection()
  DoScreenFadeOut(500)
  Siku.waitFor(function()
    return IsScreenFadedOut() or nil
  end, T('error_screen_never_faded'), 2000)

  local ped <const> = ApplyCharacterLook(SELECTION_MODEL, nil, SpawnConfig.characterSelectionSpawn)

  SetEntityVisible(ped, true, false)

  ShutdownLoadingScreen()
  ShutdownLoadingScreenNui()

  return ped
end

--- Places the fixed selection camera in front of the staged character.
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

--- Shows the look of a slot on the staged ped — the saved character, or
--- the default one when the slot is empty.
---@param slot number The slot to show.
---@return nil
local function showSlot(slot)
  local look <const> = looks[slot]
  local ped <const> = ApplyCharacterLook(
    look and look.model or SELECTION_MODEL,
    look and look.appearance or nil,
    SpawnConfig.characterSelectionSpawn
  )

  SetEntityVisible(ped, true, false)
end

--- Destroys the selection camera once the screen is over.
---@return nil
function ClearSelectionCamera()
  if not selectionCamera then
    return
  end

  Siku.camera.destroy(selectionCamera)
  selectionCamera = nil
  looks = {}
end

RegisterNUICallback('siku_multicharacter:nui:slotChanged', function(data, cb)
  cb({})

  if type(data) ~= 'table' or type(data.slot) ~= 'number' then
    return
  end

  CreateThread(function()
    showSlot(data.slot)
  end)
end)

RegisterNetEvent('siku_multicharacter:client:prepareCharacterSelect', function()
  local ped <const> = stageForSelection()

  placeSelectionCamera(ped)

  local ok <const>, payload = Siku.callback.triggerServer('siku_multicharacter:callback:getCharacters')

  if not ok then
    Siku.print.error(T('error_characters_fetch_failed', tostring(payload)))
    return
  end

  looks = payload.looks or {}

  local characters <const> = payload.characters or {}

  SendNUIMessage({
    action = 'siku_multicharacter:nui:setCharacters',
    characters = characters,
    config = payload.config or {},
  })

  if characters[1] then
    showSlot(characters[1].slot)
  end

  SetNuiFocus(true, true)
  SendNUIMessage({ action = 'siku_multicharacter:nui:setScreen', screen = 'selection' })

  DoScreenFadeIn(800)

  Siku.print.debug(('Character selection opened with %d character(s)'):format(#characters))
end)
