local OPEN_EVENT <const> = 'siku_multicharacter:client:open'
local RELOG_EVENT <const> = 'siku_multicharacter:client:relog'
local RELOG_COOLDOWN_MS <const> = 5000

Siku.command.register('relog', function(src)
  local user <const> = Siku.cache.getPlayer(src)

  if not user then
    return
  end

  local characterId <const> = Siku.cache.getCurrentCharacterId(src)

  if not characterId then
    Siku.notification.show(src, {
      type = 'info',
      title = T('relog_title'),
      description = T('relog_no_character'),
    })
    return
  end

  local character <const> = Siku.cache.getCurrentCharacter(src)
  local previous <const>, seconds <const> = Flow.enter(src, 'selection')

  Siku.log.info('multicharacter.relog', ('%s left %s after %ds to pick a character'):format(user.name, character and character:getFullName() or ('character ' .. characterId), seconds), {
    characterId = characterId,
    playSeconds = seconds,
    previous = previous,
  }, { source = src, entities = { { type = 'player', id = src, role = 'actor' } } })

  TriggerClientEvent(RELOG_EVENT, src)

  Siku.persistence.savePlayer(src)
  Siku.cache.releaseCurrentCharacter(src)

  if SpawnConfig.privateInstance and not Siku.bucket.isPlayerInstanced(src) then
    Siku.bucket.createPlayerInstance(src)
  end

  TriggerClientEvent(OPEN_EVENT, src, 'selection')
end, {
  cooldown = RELOG_COOLDOWN_MS,
  description = 'Quitte le personnage en cours et revient à la sélection.',
})
