# siku_multicharacter

The official multicharacter system of the SIKU ecosystem — a modern, modular and immersive resource for creating, managing, and selecting player characters with seamless integration and a polished user experience.

![Version](https://img.shields.io/badge/version-1.0.0-4785bd)
![FiveM](https://img.shields.io/badge/fx__version-cerulean-4785bd)
![Lua](https://img.shields.io/badge/Lua-5.4-4785bd)
![Vue](https://img.shields.io/badge/NUI-Vue%203-4785bd)

## Features

- **Full first-connection flow** — the user row is created from the player's identifiers on first join, then every session is routed straight to selection or creation. Players can be isolated in a private routing bucket until they spawn.
- **Character selection** — slot list with identity, occupation, playtime and last-played, a fixed cinematic camera, and a live ped preview that re-dresses itself as slots are browsed.
- **Identity creation** — validated form (names, gender, nationality, birth date with calendar, birth place, height), server-side re-validation, live preview.
- **Appearance editor** — a scripted intro camera glides from the sky to the character, then a free camera takes over: cursor-directed zoom, pan and orbit. Heritage, physical traits, clothing, accessories and tattoos, with every slider limit queried from the game itself so the interface always matches what the server streams. Per-gender tattoo catalogues and a final summary step.
- **Deletion with guardrails** — optional (`playerCanDeleteCharacter`), confirmation modal, ownership-scoped delete, automatic re-routing to selection or creation.
- **Clean spawning** — appearance applied, collision awaited, camera handed back, controls restored, fade-in.
- **3 interface themes** — Glass, Minimal and Dark, all shipping in the same build and selected by configuration.
- **Ecosystem heart** — this resource fires the character lifecycle events the whole ecosystem builds on: the core caches the user and character, and resources like the inventory and the status system load their data the moment a character becomes active.
- **i18n pipeline** — the server language is pushed to the NUI at runtime (`fr` / `en`).

## Dependencies

| Resource | Required | Purpose |
|---|---|---|
| [`siku_core`](https://github.com/siku-project/siku_core) | Yes | Framework core: user/character classes and cache, buckets, cameras, callbacks — and the `users` / `characters` schema, created by the core migration. |
| [oxmysql](https://github.com/CommunityOx/oxmysql) | Yes | Database access. |

`siku_core` must be started **before** `siku_multicharacter`. There is no SQL file to import: the tables this resource reads and writes belong to the core schema.

## Installation

### From a release (recommended)

Download the latest [release](https://github.com/siku-project/siku_multicharacter/releases) zip and extract it into your server resources folder. The zip ships with the NUI **already built** — no build step, ready to run.

### From source

```bash
git clone git@github.com:siku-project/siku_multicharacter.git
cd siku_multicharacter/web
bun install
bun run build
```

### server.cfg

```cfg
ensure oxmysql
ensure siku_core
ensure siku_multicharacter
```

## Configuration

All options live in `config/` and are documented inline.

| File | Options |
|---|---|
| `config/spawn.lua` | `characterSlots`, `playerCanDeleteCharacter`, `characterSelectionSpawn`, `playerInstance` (private bucket during selection), `spawnPosition` |
| `config/interface.lua` | `theme` (`glass` / `minimal` / `dark`) |
| `config/character.lua` | The default look applied to a fresh character. |
| `config/peds.lua` | The ped models offered by the appearance editor. |
| `config/heritage.lua` | The parent faces available to heritage blending. |
| `config/tattoos.lua` | The full tattoo catalogue, by zone and gender. |
| `config/translation.lua` | `language` (`fr` / `en`) |

## Lifecycle contract

This resource decides when a user and a character enter play, and announces it to the ecosystem:

| Event | Fired when |
|---|---|
| `siku:server:createUserInstance` | The player's user row was found or created. |
| `siku:server:createCharacterInstance` | A character was created or chosen and is about to spawn. |

The core consumes these to build and cache its `User` and `Character` instances; any resource owning per-character data (inventory, statuses…) listens to the same events to load it.

## Development

The NUI lives in `web/` (Vue 3, Pinia, Tailwind, Vite — built with [bun](https://bun.sh)).

```bash
cd web
bun install
bun dev          # browser playground with mocked characters, peds and heritage
bun run build    # production build → web/dist
bun run check    # format + type-check + lint
```

In development the app boots into a view selector covering every screen in every theme, fed by offline mocks; in production only the configured theme ships.

```
siku_multicharacter/
├── client/modules/    # session routing, selection, creation cameras, appearance, spawn
├── server/modules/    # user entry point, selection callback, create / play / delete
├── config/            # spawn, interface, peds, heritage, tattoos, language
├── translations/      # fr / en
└── web/               # Vue 3 NUI — three themes, mocks, dev harness
```

## Credits

Part of the [SIKU project](https://github.com/siku-project) — © Siku Studio.
