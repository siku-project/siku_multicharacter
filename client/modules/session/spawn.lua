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
  elseif not data.handover then
    SetEntityCoordsNoOffset(ped, spawn.x, spawn.y, spawn.z, false, false, false)
    SetEntityHeading(ped, spawn.w)
  end

  if not data.handover then
    RequestCollisionAtCoord(spawn.x, spawn.y, spawn.z)
    Siku.waitFor(function()
      return HasCollisionLoadedAroundEntity(ped) or nil
    end, T('error_collision_never_loaded'), 10000)
  end

  local camera <const> = GetCreationCamera()

  if camera then
    Siku.camera.destroy(camera)
    ClearCreationCamera()
  end

  ClearSelectionCamera()

  SetEntityVisible(ped, true, false)
  FreezeEntityPosition(ped, false)

  if data.handover then
    --- The introduction takes over from here: it places the character,
    --- fades in on its own first shot, and gives control back at the end.
    Siku.print.debug('Character handed over to the introduction')
    return
  end

  SetEntityInvincible(ped, false)
  SetPlayerControl(PlayerId(), true, 0)
  SetPlayerInvincible(PlayerId(), false)

  DoScreenFadeIn(800)
  Siku.print.debug('Character spawned in the world')
end)
