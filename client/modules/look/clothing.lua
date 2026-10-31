Look = Look or {}

local SLOTS <const> = {
  { key = 'jacket', component = 11 },
  { key = 'tshirt', component = 8 },
  { key = 'armsGloves', component = 3 },
  { key = 'pants', component = 4 },
  { key = 'shoes', component = 6 },
}

---@param ped number The ped handle.
---@param component number
---@param entry table { model, variant }, 1-based as the interface counts.
local function dress(ped, component, entry)
  local drawable <const> = math.max((entry.model or 1) - 1, 0)
  local textures <const> = GetNumberOfPedTextureVariations(ped, component, drawable)
  local texture <const> = math.min(math.max((entry.variant or 1) - 1, 0), math.max(textures - 1, 0))

  SetPedComponentVariation(ped, component, drawable, texture, 0)
end

---@param ped number The ped handle.
---@param limits table Filled with the drawable and texture counts of each slot.
---@return table limits
function Look.clothingLimits(ped, limits)
  for i = 1, #SLOTS do
    local slot <const> = SLOTS[i]
    local drawable <const> = GetPedDrawableVariation(ped, slot.component)

    limits[slot.key .. 'Model'] = GetNumberOfPedDrawableVariations(ped, slot.component)
    limits[slot.key .. 'Variant'] = GetNumberOfPedTextureVariations(ped, slot.component, drawable)
  end

  return limits
end

---@param ped number The ped handle.
---@param data table|nil The clothing payload, by slot key.
function Look.applyClothing(ped, data)
  if type(data) ~= 'table' then
    return
  end

  for i = 1, #SLOTS do
    local slot <const> = SLOTS[i]

    if data[slot.key] then
      dress(ped, slot.component, data[slot.key])
    end
  end
end

Nui.on('clothingChanged', function(data)
  local ped <const> = PlayerPedId()

  Look.applyClothing(ped, data)
  Look.sendLimits(Look.clothingLimits(ped, {}))
end)
