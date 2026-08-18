local COMPONENT_SLOTS <const> = {
  { key = 'mask', component = 1 },
  { key = 'backpack', component = 5 },
  { key = 'neckwear', component = 7 },
}

local PROP_SLOTS <const> = {
  { key = 'hat', prop = 0 },
  { key = 'glasses', prop = 1 },
  { key = 'earrings', prop = 2 },
  { key = 'watch', prop = 6 },
  { key = 'bracelet', prop = 7 },
}

--- Sends the accessory counts of the current ped to the NUI. Prop slots
--- reserve their first slider value for "none", and texture counts
--- depend on the drawable currently worn, so this runs again after
--- every change.
---@param ped number The ped handle.
---@return nil
function SendAccessoryLimits(ped)
  local limits <const> = {}

  for i = 1, #COMPONENT_SLOTS do
    local slot <const> = COMPONENT_SLOTS[i]
    local drawable <const> = GetPedDrawableVariation(ped, slot.component)

    limits[slot.key .. 'Model'] = GetNumberOfPedDrawableVariations(ped, slot.component)
    limits[slot.key .. 'Variant'] = GetNumberOfPedTextureVariations(ped, slot.component, drawable)
  end

  for i = 1, #PROP_SLOTS do
    local slot <const> = PROP_SLOTS[i]
    local drawable <const> = GetPedPropIndex(ped, slot.prop)
    local textureCount <const> = drawable >= 0
      and GetNumberOfPedPropTextureVariations(ped, slot.prop, drawable)
      or 0

    limits[slot.key .. 'Model'] = GetNumberOfPedPropDrawableVariations(ped, slot.prop) + 1
    limits[slot.key .. 'Variant'] = math.max(textureCount, 1)
  end

  SendNUIMessage({
    action = 'siku_multicharacter:nui:setLimits',
    limits = limits,
  })
end

--- Applies an accessory payload to the player ped.
---@param data table The accessory payload, indexed by slot key.
---@return nil
function ApplyAccessories(data)
  if type(data) ~= 'table' then
    return
  end

  local ped <const> = PlayerPedId()

  for i = 1, #COMPONENT_SLOTS do
    local slot <const> = COMPONENT_SLOTS[i]
    local entry <const> = data[slot.key]

    if entry then
      local drawable <const> = math.max((entry.model or 1) - 1, 0)
      local textureCount <const> = GetNumberOfPedTextureVariations(ped, slot.component, drawable)
      local texture <const> = math.min(math.max((entry.variant or 1) - 1, 0), math.max(textureCount - 1, 0))

      SetPedComponentVariation(ped, slot.component, drawable, texture, 0)
    end
  end

  for i = 1, #PROP_SLOTS do
    local slot <const> = PROP_SLOTS[i]
    local entry <const> = data[slot.key]

    if entry then
      local drawable <const> = (entry.model or 1) - 2

      if drawable < 0 then
        ClearPedProp(ped, slot.prop)
      else
        local textureCount <const> = GetNumberOfPedPropTextureVariations(ped, slot.prop, drawable)
        local texture <const> = math.min(math.max((entry.variant or 1) - 1, 0), math.max(textureCount - 1, 0))

        SetPedPropIndex(ped, slot.prop, drawable, texture, true)
      end
    end
  end

  SendAccessoryLimits(ped)
end

RegisterNUICallback('siku_multicharacter:nui:accessoriesChanged', function(data, cb)
  cb({})
  ApplyAccessories(data)
end)
