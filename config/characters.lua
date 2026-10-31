CharactersConfig = {
  --- Maximum number of characters a player can own.
  ---
  --- Drives the number of slots shown on the selection screen; a player
  --- with every slot used must delete a character (when allowed) before
  --- creating a new one.
  ---
  --- Default: 2
  slots = 2,

  --- Whether players can delete their own characters from the selection
  --- screen.
  ---
  --- Deletion is permanent: the character and everything attached to it
  --- are removed. Keep it disabled to route deletions through the staff.
  ---
  --- Default: false
  allowDeletion = false,

  --- Whether a character left dead comes back dead.
  ---
  --- The core flags a character dead the moment its ped dies and alive
  --- when it gets back up. Enabled, a character whose flag is set spawns
  --- dead where it was, so a disconnect is no way out. Disabled, the flag
  --- is cleared on entry and the character spawns standing.
  ---
  --- Default: true
  deathPersistence = true,

  --- Age bounds accepted at creation, in years.
  minAge = 18,
  maxAge = 110,

  --- Height bounds accepted at creation, in centimetres.
  minHeight = 120,
  maxHeight = 220,
}
