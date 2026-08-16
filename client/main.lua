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
  Siku.WaitFor(function()
    return NetworkIsSessionStarted() or nil
  end, 'network session never started', false)

  Siku.print.debug("Session detected and player arrived !")
  announceReady()
end)
