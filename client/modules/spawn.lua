local COLLISION_TIMEOUT <const> = 10000

---@param spot vector4 Where the character enters the world.
---@param model string The ped model name.
---@param appearance table|nil The saved appearance.
---@return number ped The dressed ped, placed at the spot.
local function placeInWorld(spot, model, appearance)
  local modelHash <const> = Siku.streaming.requestModel(model)

  SetPlayerModel(PlayerId(), modelHash)
  SetModelAsNoLongerNeeded(modelHash)

  local ped <const> = PlayerPedId()

  Look.apply(ped, model, appearance)
  SetEntityCoordsNoOffset(ped, spot.x, spot.y, spot.z, false, false, false)
  SetEntityHeading(ped, spot.w)

  return ped
end

RegisterNetEvent('siku_multicharacter:client:spawn', function(data)
  if type(data) ~= 'table' or type(data.position) ~= 'table' then
    return
  end

  local position <const> = data.position
  local spot <const> = vector4(position.x + 0.0, position.y + 0.0, position.z + 0.0, (position.heading or 0.0) + 0.0)

  Pose.reset()
  Camera.clear()
  Stage.leave()

  local ped <const> = placeInWorld(spot, data.model, data.appearance)

  if not data.handover then
    RequestCollisionAtCoord(spot.x, spot.y, spot.z)
    Siku.waitFor(function()
      return HasCollisionLoadedAroundEntity(ped) or nil
    end, T('error_collision_never_loaded'), COLLISION_TIMEOUT)
  end

  SetEntityVisible(ped, true, false)
  FreezeEntityPosition(ped, false)
  Hud.show()

  if data.handover then
    return
  end

  SetEntityInvincible(ped, false)
  SetPlayerControl(PlayerId(), true, 0)
  SetPlayerInvincible(PlayerId(), false)

  if data.dead then
    SetEntityHealth(ped, 0)
  end

  DoScreenFadeIn(800)
end)
