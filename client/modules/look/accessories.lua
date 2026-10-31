Look = Look or {}

local COMPONENTS <const> = {
  { key = 'mask', component = 1 },
  { key = 'backpack', component = 5 },
  { key = 'neckwear', component = 7 },
}

local PROPS <const> = {
  { key = 'hat', prop = 0 },
  { key = 'glasses', prop = 1 },
  { key = 'earrings', prop = 2 },
  { key = 'watch', prop = 6 },
  { key = 'bracelet', prop = 7 },
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
---@param prop number
---@param entry table { model, variant }; model 1 means none.
local function wear(ped, prop, entry)
  local drawable <const> = (entry.model or 1) - 2

  if drawable < 0 then
    ClearPedProp(ped, prop)
    return
  end

  local textures <const> = GetNumberOfPedPropTextureVariations(ped, prop, drawable)
  local texture <const> = math.min(math.max((entry.variant or 1) - 1, 0), math.max(textures - 1, 0))

  SetPedPropIndex(ped, prop, drawable, texture, true)
end

---@param ped number The ped handle.
---@param limits table Filled with the counts of each slot; props reserve their first value for none.
---@return table limits
function Look.accessoryLimits(ped, limits)
  for i = 1, #COMPONENTS do
    local slot <const> = COMPONENTS[i]
    local drawable <const> = GetPedDrawableVariation(ped, slot.component)

    limits[slot.key .. 'Model'] = GetNumberOfPedDrawableVariations(ped, slot.component)
    limits[slot.key .. 'Variant'] = GetNumberOfPedTextureVariations(ped, slot.component, drawable)
  end

  for i = 1, #PROPS do
    local slot <const> = PROPS[i]
    local drawable <const> = GetPedPropIndex(ped, slot.prop)
    local textures <const> = drawable >= 0 and GetNumberOfPedPropTextureVariations(ped, slot.prop, drawable) or 0

    limits[slot.key .. 'Model'] = GetNumberOfPedPropDrawableVariations(ped, slot.prop) + 1
    limits[slot.key .. 'Variant'] = math.max(textures, 1)
  end

  return limits
end

---@param ped number The ped handle.
---@param data table|nil The accessory payload, by slot key.
function Look.applyAccessories(ped, data)
  if type(data) ~= 'table' then
    return
  end

  for i = 1, #COMPONENTS do
    local slot <const> = COMPONENTS[i]

    if data[slot.key] then
      dress(ped, slot.component, data[slot.key])
    end
  end

  for i = 1, #PROPS do
    local slot <const> = PROPS[i]

    if data[slot.key] then
      wear(ped, slot.prop, data[slot.key])
    end
  end
end

Nui.on('accessoriesChanged', function(data)
  local ped <const> = PlayerPedId()

  Look.applyAccessories(ped, data)
  Look.sendLimits(Look.accessoryLimits(ped, {}))
end)
