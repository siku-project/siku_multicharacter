RegisterNUICallback('siku_multicharacter:nui:playCharacter', function(data, cb)
  cb({})

  if type(data) ~= 'table' or type(data.id) ~= 'number' then
    return
  end

  CreateThread(function()
    SendNUIMessage({ action = 'siku_multicharacter:nui:setScreen', screen = 'hidden' })
    SetNuiFocus(false, false)

    DoScreenFadeOut(600)
    Siku.waitFor(function()
      return IsScreenFadedOut() or nil
    end, T('error_screen_never_faded'), 2000)

    TriggerServerEvent('siku_multicharacter:server:playCharacter', data.id)
  end)
end)
