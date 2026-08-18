--- Decodes the appearance column of a character row.
---@param encoded string|nil The stored JSON.
---@return table|nil appearance The decoded appearance, or nil when absent or unreadable.
function DecodeCharacterAppearance(encoded)
  if type(encoded) ~= 'string' or encoded == '' then
    return nil
  end

  local ok <const>, decoded = pcall(json.decode, encoded)

  return ok and decoded or nil
end
