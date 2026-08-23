RegisterNUICallback('siku_multicharacter:nui:deleteCharacter', function(data, cb)
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

    ClearSelectionCamera()

    TriggerServerEvent('siku_multicharacter:server:deleteCharacter', data.id)
  end)
end)
