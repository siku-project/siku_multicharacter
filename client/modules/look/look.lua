Look = Look or {}

Look.FREEMODE = {
  mp_m_freemode_01 = 'm',
  mp_f_freemode_01 = 'f',
}

---@param model string The ped model name.
---@return string|nil gender 'm' or 'f' for a freemode ped, nil otherwise.
function Look.genderOf(model)
  return Look.FREEMODE[model]
end

---@param ped number
---@return string|nil gender
function Look.genderOfPed(ped)
  local model <const> = GetEntityModel(ped)

  for name, gender in pairs(Look.FREEMODE) do
    if joaat(name) == model then
      return gender
    end
  end

  return nil
end

---@param ped number The ped handle.
---@param model string The ped model name.
---@param appearance table|nil A saved appearance { heritage, physical, clothing, accessories, tattoos }.
function Look.apply(ped, model, appearance)
  local gender <const> = Look.genderOf(model)

  if gender then
    Look.applyDefault(ped, gender)
  end

  if type(appearance) ~= 'table' then
    return
  end

  Look.applyHeritage(ped, appearance.heritage)
  Look.applyPhysical(ped, appearance.physical)
  Look.applyClothing(ped, appearance.clothing)
  Look.applyAccessories(ped, appearance.accessories)
  Look.applyTattoos(ped, appearance.tattoos)
end

---@param limits table The limits to send, keyed as the interface reads them.
function Look.sendLimits(limits)
  Nui.send('setLimits', { limits = limits })
end

---@param ped number The ped handle.
function Look.sendAllLimits(ped)
  local limits <const> = {}

  if Look.genderOfPed(ped) then
    Look.physicalLimits(ped, limits)
  end

  Look.clothingLimits(ped, limits)
  Look.accessoryLimits(ped, limits)
  Look.tattooLimits(ped, limits)

  Look.sendLimits(limits)
end
