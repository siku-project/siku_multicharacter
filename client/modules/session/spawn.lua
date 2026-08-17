RegisterNetEvent('siku_multicharacter:client:spawnCharacter', function(position)
  if type(position) ~= 'table' then
    return
  end

  local ped <const> = PlayerPedId()

  SetEntityCoordsNoOffset(ped, position.x + 0.0, position.y + 0.0, position.z + 0.0, false, false, false)
  SetEntityHeading(ped, position.heading + 0.0)

  RequestCollisionAtCoord(position.x + 0.0, position.y + 0.0, position.z + 0.0)
  Siku.WaitFor(function()
    return HasCollisionLoadedAroundEntity(ped) or nil
  end, T('error_collision_never_loaded'), 10000)

  local camera <const> = GetCreationCamera()

  if camera then
    Siku.camera.destroy(camera)
    ClearCreationCamera()
  end

  SetEntityVisible(ped, true, false)
  FreezeEntityPosition(ped, false)
  SetPlayerControl(PlayerId(), true, 0)
  SetPlayerInvincible(PlayerId(), false)

  DoScreenFadeIn(800)
  Siku.print.debug('Character spawned in the world')
end)
