Stage = {}

local DEFAULT_MODEL <const> = 'mp_m_freemode_01'

local staged = false

function Stage.fadeOut()
  DoScreenFadeOut(500)
  Siku.waitFor(function()
    return IsScreenFadedOut() or nil
  end, T('error_screen_never_faded'), 2000)
end

---@param model string|nil The ped model, defaulting to the male freemode.
---@param appearance table|nil A saved appearance to dress the ped with.
---@return number ped The staged ped handle.
function Stage.place(model, appearance)
  local pedModel <const> = model and model ~= '' and model or DEFAULT_MODEL
  local spot <const> = SpawnConfig.staging

  Pose.reset()

  local modelHash <const> = Siku.streaming.requestModel(pedModel)

  SetPlayerModel(PlayerId(), modelHash)
  SetModelAsNoLongerNeeded(modelHash)

  local ped <const> = PlayerPedId()

  SetEntityCoords(ped, spot.x, spot.y, spot.z, false, false, false, true)
  SetEntityHeading(ped, spot.w)
  FreezeEntityPosition(ped, true)
  SetEntityInvincible(ped, true)
  SetPlayerControl(PlayerId(), false, 0)

  Look.apply(ped, pedModel, appearance)
  SetEntityVisible(ped, true, false)

  return ped
end

---@return number ped The staged ped handle.
function Stage.enter()
  if not staged then
    staged = true

    Stage.fadeOut()
    Hud.hide()
  end

  local ped <const> = Stage.place(DEFAULT_MODEL, nil)

  ShutdownLoadingScreen()
  ShutdownLoadingScreenNui()

  return ped
end

function Stage.leave()
  staged = false
end
