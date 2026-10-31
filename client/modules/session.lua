local announced = false

CreateThread(function()
  Siku.waitFor(function()
    return NetworkIsPlayerActive(PlayerId()) or nil
  end, T('error_session_never_started'), false)

  if announced then
    return
  end

  announced = true

  TriggerServerEvent('siku_multicharacter:server:playerReady')
end)

RegisterNetEvent('siku_multicharacter:client:open', function(screen)
  if screen == 'selection' then
    Selection.open()
  elseif screen == 'creation' then
    Creation.open()
  end
end)
