RegisterNUICallback('siku_multicharacter:nui:appearanceValidated', function(data, cb)
  cb({})

  if type(data) ~= 'table' then
    return
  end

  local identity <const> = GetIdentityDraft()

  if not identity then
    Siku.print.error(T('error_missing_identity'))
    return
  end

  CreateThread(function()
    SendNUIMessage({ action = 'siku_multicharacter:nui:setScreen', screen = 'hidden' })
    SetNuiFocus(false, false)

    DoScreenFadeOut(600)
    Siku.waitFor(function()
      return IsScreenFadedOut() or nil
    end, T('error_screen_never_faded'), 2000)

    TriggerServerEvent('siku_multicharacter:server:createCharacter', {
      identity = identity,
      pedModel = data.pedModel,
      appearance = data.appearance,
    })
  end)
end)
