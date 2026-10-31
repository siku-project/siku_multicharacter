<script lang="ts">
  import {
    Avatar,
    Button,
    Combobox,
    DateField,
    Divider,
    Segmented,
    Slider,
    Surface,
    TextField,
  } from '@siku/ui'
  import Brand from '@/components/shared/Brand.svelte'
  import Progress from '@/components/shared/Progress.svelte'
  import { m } from '@/lib/i18n.svelte'
  import { locale } from '@/lib/locale.svelte'
  import { game } from '@/lib/multicharacter/bridge'
  import { countryOptions } from '@/lib/multicharacter/countries'
  import { formatDate } from '@/lib/multicharacter/format'
  import {
    HEIGHT_MAX,
    HEIGHT_MIN,
    IDENTITY_FIELD_TOTAL,
    NAME_MAX_LENGTH,
    PLACE_MAX_LENGTH,
    birthYearBounds,
    countFilledIdentityFields,
    createIdentityDraft,
    isIdentityDraftValid,
    parseIsoDate,
    validateIdentity,
    type IdentityError,
  } from '@/lib/multicharacter/identity'
  import { store } from '@/lib/multicharacter/store.svelte'

  const draft = $state(createIdentityDraft())
  const bounds = birthYearBounds()

  const countries = $derived(countryOptions(locale.current))
  const errors = $derived(validateIdentity(draft))
  const valid = $derived(isIdentityDraftValid(draft))
  const filled = $derived(countFilledIdentityFields(draft))
  let nationality = $state<string | string[]>('')

  $effect(() => {
    draft.nationality = typeof nationality === 'string' ? nationality : ''
  })

  const message = (error: IdentityError | undefined): string | undefined => {
    switch (error?.code) {
      case 'nameLength':
        return m.creation_errorNameLength({ min: error.min })
      case 'nameCapital':
        return m.creation_errorNameCapital()
      case 'dateInvalid':
        return m.creation_errorDateInvalid()
      case 'ageMin':
        return m.creation_errorAgeMin({ min: error.min })
      case 'ageMax':
        return m.creation_errorAgeMax({ max: error.max })
      case 'heightRange':
        return m.creation_errorHeightRange({ min: error.min, max: error.max })
      default:
        return undefined
    }
  }

  const heroName = $derived(`${draft.firstName} ${draft.lastName}`.trim())

  const summary = $derived.by(() => {
    const parts: string[] = [draft.gender === 'female' ? m.creation_female() : m.creation_male()]
    const country = countries.find((option) => option.value === draft.nationality)
    const birth = parseIsoDate(draft.birthDate)

    if (country) {
      parts.push(country.label)
    }

    if (birth && !errors.birthDate) {
      parts.push(formatDate(birth, locale.current))
    }

    if (draft.birthPlace.trim()) {
      parts.push(draft.birthPlace.trim())
    }

    parts.push(`${draft.height} cm`)

    return parts.join(' · ')
  })

  const remaining = $derived(IDENTITY_FIELD_TOTAL - filled)

  const status = $derived(
    valid
      ? m.creation_ready()
      : remaining === 1
        ? m.creation_remainingOne()
        : m.creation_remaining({ count: remaining }),
  )

  const submit = (event?: Event): void => {
    event?.preventDefault()

    if (!valid) {
      return
    }

    const identity = {
      ...draft,
      firstName: draft.firstName.trim(),
      lastName: draft.lastName.trim(),
      birthPlace: draft.birthPlace.trim(),
    }

    store.setIdentity(identity)
    void game.identitySubmitted(identity)
  }
</script>

<div class="fixed inset-0 z-panel flex items-center justify-center">
  <div class="absolute inset-0 bg-bg-void opacity-scrim-heavy" aria-hidden="true"></div>

  <Surface elevated padding="none" class="relative flex w-[40rem] flex-col">
    <form class="flex flex-col" onsubmit={submit}>
      <header class="flex items-center justify-between gap-8 px-8 py-5">
        <Brand tagline={m.creation_civilStatus()} />
        <Progress value={filled} max={IDENTITY_FIELD_TOTAL} label={m.creation_progress()} />
      </header>

      <Divider />

      <div class="flex items-center gap-4 bg-bg-raised px-8 py-4">
        <Avatar name={heroName || '?'} />
        <div class="flex min-w-0 flex-col gap-0.5">
          <span class="t-subheading truncate" class:text-fg-tertiary={!heroName}>
            {heroName || m.creation_previewEmpty()}
          </span>
          <span class="t-caption truncate text-fg-tertiary">{summary}</span>
        </div>
      </div>

      <Divider />

      <div class="flex flex-col gap-6 px-8 py-6">
        <section class="flex flex-col gap-4">
          <Divider label={m.creation_sectionIdentity()} />
          <div class="grid grid-cols-2 gap-4">
            <TextField
              label={m.creation_firstName()}
              placeholder={m.creation_firstNamePlaceholder()}
              maxlength={NAME_MAX_LENGTH}
              bind:value={draft.firstName}
              error={message(errors.firstName)}
            />
            <TextField
              label={m.creation_lastName()}
              placeholder={m.creation_lastNamePlaceholder()}
              maxlength={NAME_MAX_LENGTH}
              bind:value={draft.lastName}
              error={message(errors.lastName)}
            />
            <div class="sk-field">
              <span class="sk-field__label">{m.creation_gender()}</span>
              <Segmented
                label={m.creation_gender()}
                size="lg"
                block
                bind:value={draft.gender}
                options={[
                  { value: 'male', label: m.creation_male() },
                  { value: 'female', label: m.creation_female() },
                ]}
              />
            </div>
            <Combobox
              label={m.creation_nationality()}
              placeholder={m.creation_nationalityPlaceholder()}
              searchLabel={m.creation_nationalitySearch()}
              empty={m.creation_nationalityEmpty()}
              bind:value={nationality}
              options={countries}
            />
          </div>
        </section>

        <section class="flex flex-col gap-4">
          <Divider label={m.creation_sectionBirth()} />
          <div class="grid grid-cols-2 gap-4">
            <DateField
              label={m.creation_birthDate()}
              placeholder={m.creation_datePlaceholder()}
              locale={locale.current}
              minYear={bounds.minYear}
              maxYear={bounds.maxYear}
              calendarLabel={m.creation_openCalendar()}
              placement="top-start"
              bind:value={draft.birthDate}
              error={message(errors.birthDate)}
            />
            <TextField
              label={m.creation_birthPlace()}
              placeholder={m.creation_birthPlacePlaceholder()}
              maxlength={PLACE_MAX_LENGTH}
              bind:value={draft.birthPlace}
            />
          </div>
        </section>

        <section class="flex flex-col gap-4">
          <Divider label={m.creation_sectionBody()} />
          <Slider
            label={m.creation_height()}
            bind:value={draft.height}
            min={HEIGHT_MIN}
            max={HEIGHT_MAX}
            minLabel={`${HEIGHT_MIN} cm`}
            maxLabel={`${HEIGHT_MAX} cm`}
            format={(value) => `${value} cm`}
          />
        </section>
      </div>

      <Divider />

      <footer class="flex items-center justify-between gap-5 px-8 py-5">
        <span class="t-body-sm" class:text-fg-tertiary={!valid} class:text-fg-secondary={valid}
          >{status}</span
        >
        <Button variant="primary" type="submit" key="Entrée" disabled={!valid}
          >{m.creation_continue()}</Button
        >
      </footer>
    </form>
  </Surface>
</div>
