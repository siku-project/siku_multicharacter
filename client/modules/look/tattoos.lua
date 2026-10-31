Look = Look or {}

local ZONES <const> = {
  { key = 'hair', zone = 'ZONE_HAIR' },
  { key = 'head', zone = 'ZONE_HEAD' },
  { key = 'neck', zone = 'ZONE_HEAD' },
  { key = 'torso', zone = 'ZONE_TORSO' },
  { key = 'back', zone = 'ZONE_TORSO' },
  { key = 'leftArm', zone = 'ZONE_LEFT_ARM' },
  { key = 'rightArm', zone = 'ZONE_RIGHT_ARM' },
  { key = 'leftLeg', zone = 'ZONE_LEFT_LEG' },
  { key = 'rightLeg', zone = 'ZONE_RIGHT_LEG' },
}

local catalogues = {}

---@param zone string The tattoo zone name.
---@param gender 'm'|'f'
---@return table tattoos The tattoos of the zone the gender can wear, each { collection, hash }.
local function zoneCatalogue(zone, gender)
  local source <const> = TattooConfig[zone] or {}
  local tattoos <const> = {}

  for i = 1, #source do
    local tattoo <const> = source[i]
    local hash <const> = gender == 'f' and tattoo.female or tattoo.male

    if hash and hash ~= '' then
      tattoos[#tattoos + 1] = { collection = tattoo.collection, hash = hash }
    end
  end

  return tattoos
end

---@param gender 'm'|'f'
---@return table catalogue The tattoos by slot key, built once per gender.
local function catalogueOf(gender)
  if not catalogues[gender] then
    local catalogue <const> = {}

    for i = 1, #ZONES do
      catalogue[ZONES[i].key] = zoneCatalogue(ZONES[i].zone, gender)
    end

    catalogues[gender] = catalogue
  end

  return catalogues[gender]
end

---@param ped number The ped handle.
---@param limits table Filled with the count of each zone; the first value is reserved for none.
---@return table limits
function Look.tattooLimits(ped, limits)
  local catalogue <const> = catalogueOf(Look.genderOfPed(ped) or 'm')

  for i = 1, #ZONES do
    limits[ZONES[i].key .. 'Tattoo'] = #catalogue[ZONES[i].key] + 1
  end

  return limits
end

---@param ped number The ped handle.
---@param data table|nil The tattoo payload, by zone key, 1 meaning none.
function Look.applyTattoos(ped, data)
  if type(data) ~= 'table' then
    return
  end

  local catalogue <const> = catalogueOf(Look.genderOfPed(ped) or 'm')

  ClearPedDecorations(ped)

  for i = 1, #ZONES do
    local key <const> = ZONES[i].key
    local index <const> = (data[key] or 1) - 1
    local tattoo <const> = index > 0 and catalogue[key][index] or nil

    if tattoo then
      AddPedDecorationFromHashes(ped, joaat(tattoo.collection), joaat(tattoo.hash))
    end
  end
end

Nui.on('tattoosChanged', function(data)
  Look.applyTattoos(PlayerPedId(), data)
end)
