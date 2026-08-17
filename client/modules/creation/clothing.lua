local CLOTHING_SLOTS <const> = {
  { key = 'jacket', component = 11 },
  { key = 'tshirt', component = 8 },
  { key = 'armsGloves', component = 3 },
  { key = 'pants', component = 4 },
  { key = 'shoes', component = 6 },
}

--- Sends the clothing counts of the current ped to the NUI. Texture
--- counts depend on the drawable currently worn, so this runs again
--- after every change.
---@param ped number The ped handle.
---@return nil
function SendClothingLimits(ped)
  local limits <const> = {}

  for i = 1, #CLOTHING_SLOTS do
    local slot <const> = CLOTHING_SLOTS[i]
    local drawable <const> = GetPedDrawableVariation(ped, slot.component)

    limits[slot.key .. 'Model'] = GetNumberOfPedDrawableVariations(ped, slot.component)
    limits[slot.key .. 'Variant'] = GetNumberOfPedTextureVariations(ped, slot.component, drawable)
  end

  SendNUIMessage({
    action = 'siku_multicharacter:nui:setLimits',
    limits = limits,
  })
end

RegisterNUICallback('siku_multicharacter:nui:clothingChanged', function(data, cb)
  cb({})

  if type(data) ~= 'table' then
    return
  end

  local ped <const> = PlayerPedId()

  for i = 1, #CLOTHING_SLOTS do
    local slot <const> = CLOTHING_SLOTS[i]
    local entry <const> = data[slot.key]

    if entry then
      local drawable <const> = math.max((entry.model or 1) - 1, 0)
      local textureCount <const> = GetNumberOfPedTextureVariations(ped, slot.component, drawable)
      local texture <const> = math.min(math.max((entry.variant or 1) - 1, 0), math.max(textureCount - 1, 0))

      SetPedComponentVariation(ped, slot.component, drawable, texture, 0)
    end
  end

  SendClothingLimits(ped)
end)
