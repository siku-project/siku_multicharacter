Selection = {}

local looks = {}

---@param slot number
local function showSlot(slot)
  local look <const> = looks[slot]

  Stage.place(look and look.model or nil, look and look.appearance or nil)
end

function Selection.open()
  local ped <const> = Stage.enter()

  Camera.placeSelection(ped)

  local ok <const>, payload = Siku.callback.triggerServer('siku_multicharacter:callback:characters')

  if not ok or type(payload) ~= 'table' then
    return
  end

  looks = payload.looks or {}

  local characters <const> = payload.characters or {}

  Nui.send('setCharacters', { characters = characters, config = payload.config or {} })

  if characters[1] then
    showSlot(characters[1].slot)
  end

  Nui.show('selection')
  DoScreenFadeIn(800)
end

Nui.on('slotChanged', function(data)
  if type(data.slot) == 'number' then
    showSlot(data.slot)
  end
end)

Nui.on('playCharacter', function(data)
  if type(data.id) ~= 'number' then
    return
  end

  Nui.hide()
  Stage.fadeOut()

  TriggerServerEvent('siku_multicharacter:server:playCharacter', data.id)
end)

Nui.on('deleteCharacter', function(data)
  if type(data.id) ~= 'number' then
    return
  end

  Nui.hide()
  Stage.fadeOut()
  Camera.clearSelection()
  looks = {}

  TriggerServerEvent('siku_multicharacter:server:deleteCharacter', data.id)
end)

Nui.on('startCreation', function()
  looks = {}
  Nui.show('creation')
end)
