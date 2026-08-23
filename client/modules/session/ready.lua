local hasAnnounced = false

--- Announces this player to the server once their network session is started.
---@return nil
local function announceReady()
  if hasAnnounced then
    return
  end
  hasAnnounced = true

  TriggerServerEvent('siku_multicharacter:server:playerReady')
  Siku.print.debug("Event Sent to server !")
end

CreateThread(function()
  Siku.waitFor(function()
    return NetworkIsPlayerActive(PlayerId()) or nil
  end, T('error_session_never_started'), false)

  Siku.print.debug("Session detected and player arrived !")
  announceReady()
end)
