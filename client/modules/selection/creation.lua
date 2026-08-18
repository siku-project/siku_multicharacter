RegisterNUICallback('siku_multicharacter:nui:startCreation', function(_, cb)
  cb({})

  ClearSelectionCamera()

  SendNUIMessage({ action = 'siku_multicharacter:nui:setScreen', screen = 'creation' })
  Siku.print.debug('Routing to character creation from the selection screen')
end)
