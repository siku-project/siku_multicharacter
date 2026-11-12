Catalog = {}

local LIST_PATH <const> = '/api/v1/files'

local described = nil
local describing = nil

local function key()
  return GetConvar(CatalogConfig.cdn.keyConvar or '', '')
end

local function encode(value)
  return (tostring(value):gsub('[^%w%-%._~]', function(char)
    return ('%%%02X'):format(char:byte())
  end))
end

---@param target string The target name, the folder of its photos.
---@param model string The ped model name.
---@return string path The folder path on the CDN, from its root.
local function folderPath(target, model)
  local parts <const> = {}
  local root <const> = (CatalogConfig.cdn.folder or ''):gsub('^/+', ''):gsub('/+$', '')

  if root ~= '' then
    parts[#parts + 1] = root
  end

  parts[#parts + 1] = target
  parts[#parts + 1] = CatalogConfig.folders[model]

  return '/' .. table.concat(parts, '/')
end

---@param path string The folder path on the CDN.
---@return table result { ok, status, items?, error?, detail? }
local function list(path)
  local cdn <const> = CatalogConfig.cdn
  local url <const> = ('%s%s?folder=%s'):format(cdn.url, LIST_PATH, encode(path))
  local done <const> = promise.new()
  local settled = false

  PerformHttpRequest(url, function(status, text)
    if settled then
      return
    end

    settled = true

    local decoded <const> = type(text) == 'string' and #text > 0 and json.decode(text) or nil

    if status >= 200 and status < 300 and type(decoded) == 'table' and type(decoded.items) == 'table' then
      done:resolve({ ok = true, status = status, items = decoded.items })
      return
    end

    local failure <const> = type(decoded) == 'table' and type(decoded.error) == 'table' and decoded.error or nil

    done:resolve({
      ok = false,
      status = status,
      error = failure and failure.code or ('http_%d'):format(status),
      detail = failure and failure.message or nil,
    })
  end, 'GET', '', { Authorization = 'Bearer ' .. key() })

  SetTimeout(cdn.timeoutMs or 10000, function()
    if not settled then
      settled = true
      done:resolve({ ok = false, status = 0, error = 'timeout' })
    end
  end)

  return Citizen.Await(done)
end

---@param items table The files the CDN listed.
---@param target string The target name the photos start with.
---@param kind string 'component' (`hair_12_0.webp`) or 'overlay' (`beard_7.webp`).
---@return table photos { { drawable, url } }, by drawable.
local function photosOf(items, target, kind)
  local pattern <const> = (kind == 'overlay' and '^%s_(%%d+)%%.webp$' or '^%s_(%%d+)_0%%.webp$'):format(target)
  local photos <const> = {}

  for i = 1, #items do
    local item <const> = items[i]
    local drawable <const> = item.kind == 'file' and type(item.name) == 'string' and item.name:match(pattern) or nil

    if drawable and type(item.url) == 'string' then
      local url <const> = item.url:match('^https?://') and item.url or (CatalogConfig.cdn.url .. item.url)

      photos[#photos + 1] = { drawable = tonumber(drawable), url = url }
    end
  end

  table.sort(photos, function(a, b)
    return a.drawable < b.drawable
  end)

  return photos
end

---@return table|nil photos By target then model, nil when nothing could be listed.
local function listAll()
  local photos <const> = {}
  local count, failures = 0, 0

  for target, kind in pairs(CatalogConfig.targets) do
    for model in pairs(CatalogConfig.folders) do
      local path <const> = folderPath(target, model)
      local result <const> = list(path)

      if result.ok then
        local entries <const> = photosOf(result.items, target, kind)

        if #entries > 0 then
          photos[target] = photos[target] or {}
          photos[target][model] = entries
          count = count + #entries
        end
      else
        failures = failures + 1

        Siku.log.warn('multicharacter.catalog_failed', ('Photos of %s could not be listed from the CDN: %s'):format(path, result.error), {
          folder = path,
          status = result.status,
          reason = result.error,
          detail = result.detail,
        }, { outcome = 'failure' })
      end
    end
  end

  if count == 0 then
    return nil
  end

  Siku.log.info('multicharacter.catalog_listed', ('%d catalogue photos listed from the CDN'):format(count), {
    photos = count,
    failures = failures,
  })

  return photos
end

---@return table|nil catalog What the interface needs to show photos, nil for sliders.
local function describe()
  if not CatalogConfig.images then
    return nil
  end

  local base <const> = {
    source = CatalogConfig.source,
    targets = CatalogConfig.targets,
    folders = CatalogConfig.folders,
  }

  if CatalogConfig.source == 'files' then
    base.folder = CatalogConfig.files.folder

    return base
  end

  if CatalogConfig.source ~= 'cdn' then
    Siku.log.warn('multicharacter.catalog_failed', ('Unknown catalogue source %s: the editor keeps its sliders'):format(tostring(CatalogConfig.source)), {
      source = tostring(CatalogConfig.source),
      reason = 'unknown_source',
    }, { outcome = 'failure' })

    return nil
  end

  if #key() == 0 then
    Siku.log.info('multicharacter.catalog_disabled', ('No CDN key in convar %s: the editor keeps its sliders'):format(CatalogConfig.cdn.keyConvar), {
      convar = CatalogConfig.cdn.keyConvar,
    })

    return nil
  end

  base.photos = listAll()

  if not base.photos then
    return nil, true
  end

  return base
end

--- What the interface needs to show the catalogue photos, listed once
--- from the CDN and kept; a listing that found nothing is tried again on
--- the next call.
---@return table|nil catalog
function Catalog.describe()
  if described ~= nil then
    return described or nil
  end

  if describing then
    return Citizen.Await(describing)
  end

  describing = promise.new()

  local catalog <const>, retry <const> = describe()

  if not retry then
    described = catalog or false
  end

  describing:resolve(catalog)
  describing = nil

  return catalog
end

Siku.callback.register('siku_multicharacter:callback:catalog', function()
  return Catalog.describe()
end)

CreateThread(function()
  Catalog.describe()
end)
