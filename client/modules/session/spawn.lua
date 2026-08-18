RegisterNetEvent('siku_multicharacter:client:spawnCharacter', function(data)
  if type(data) ~= 'table' or type(data.position) ~= 'table' then
    return
  end

  local position <const> = data.position
  local spawn <const> = vector4(
    position.x + 0.0,
    position.y + 0.0,
    position.z + 0.0,
    (position.heading or 0.0) + 0.0
  )

  local ped = PlayerPedId()

  if data.model then
    ped = ApplyCharacterLook(data.model, data.appearance, spawn)
  else
    SetEntityCoordsNoOffset(ped, spawn.x, spawn.y, spawn.z, false, false, false)
    SetEntityHeading(ped, spawn.w)
  end

  RequestCollisionAtCoord(spawn.x, spawn.y, spawn.z)
  Siku.WaitFor(function()
    return HasCollisionLoadedAroundEntity(ped) or nil
  end, T('error_collision_never_loaded'), 10000)

  local camera <const> = GetCreationCamera()

  if camera then
    Siku.camera.destroy(camera)
    ClearCreationCamera()
  end

  ClearSelectionCamera()

  SetEntityVisible(ped, true, false)
  FreezeEntityPosition(ped, false)
  SetEntityInvincible(ped, false)
  SetPlayerControl(PlayerId(), true, 0)
  SetPlayerInvincible(PlayerId(), false)

  DoScreenFadeIn(800)
  Siku.print.debug('Character spawned in the world')
end)
