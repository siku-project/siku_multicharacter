Nui = {}

local PREFIX <const> = 'siku_multicharacter:nui:'

---@param name string The message name, without the resource prefix.
---@param payload table|nil
function Nui.send(name, payload)
  local message <const> = payload or {}

  message.action = PREFIX .. name

  SendNUIMessage(message)
end

---@param screen 'selection'|'creation'|'appearance'
function Nui.show(screen)
  SikuUI.open()
  Nui.send('setScreen', { screen = screen })
end

function Nui.hide()
  Nui.send('hide')
  SikuUI.close()
end

---@param name string The callback name, without the resource prefix.
---@param handler fun(data: table) Runs in its own thread, after the interface got its answer.
function Nui.on(name, handler)
  RegisterNUICallback(PREFIX .. name, function(data, cb)
    cb({})

    CreateThread(function()
      handler(type(data) == 'table' and data or {})
    end)
  end)
end

---@param name string The callback name, without the resource prefix.
---@param handler fun(data: table): table|nil Answers the interface synchronously.
function Nui.reply(name, handler)
  RegisterNUICallback(PREFIX .. name, function(data, cb)
    cb(handler(type(data) == 'table' and data or {}) or {})
  end)
end

Nui.reply('ready', function()
  Nui.send('setPeds', {
    peds = {
      authorizeAll = PedsConfig.allowAll,
      basics = PedsConfig.basics,
      peds = PedsConfig.peds,
    },
  })

  Nui.send('setHeritage', {
    heritage = {
      fathers = HeritageConfig.fathers,
      mothers = HeritageConfig.mothers,
    },
  })

  return {
    locale = {
      language = TranslationConfig.language,
      translations = { web = Siku.locale.translations().web },
    },
  }
end)
