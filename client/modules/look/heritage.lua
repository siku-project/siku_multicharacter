Look = Look or {}

local DEFAULT_MOTHER <const> = 21
local DEFAULT_FATHER <const> = 0

---@param ped number The ped handle.
---@param data table|nil The heritage payload { mother, father, resemblance, skinTone }.
function Look.applyHeritage(ped, data)
  if type(data) ~= 'table' then
    return
  end

  local mother <const> = data.mother or DEFAULT_MOTHER
  local father <const> = data.father or DEFAULT_FATHER

  SetPedHeadBlendData(
    ped,
    mother, father, 0,
    mother, father, 0,
    (data.resemblance or 0.5) + 0.0, (data.skinTone or 0.5) + 0.0, 0.0, false
  )
end

Nui.on('heritageChanged', function(data)
  Look.applyHeritage(PlayerPedId(), data)
end)
