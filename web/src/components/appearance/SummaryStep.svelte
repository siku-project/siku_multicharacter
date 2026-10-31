<script lang="ts">
  import { Divider } from '@siku/ui'
  import { m, tr } from '@/lib/i18n.svelte'
  import { locale } from '@/lib/locale.svelte'
  import {
    APPEARANCE_STEPS,
    BASIC_PED_LABELS,
    controlKey,
    type AppearanceCategory,
    type AppearanceControl,
  } from '@/lib/multicharacter/appearance/catalog'
  import { formatDate, regionName } from '@/lib/multicharacter/format'
  import { ageAt, createIdentityDraft, parseIsoDate } from '@/lib/multicharacter/identity'
  import { store } from '@/lib/multicharacter/store.svelte'

  interface Row {
    key: string
    label: string
    value: string
    color?: string
    mono?: string
  }

  let { draft, pedModel }: { draft: Record<string, number>; pedModel: string } = $props()

  const identity = $derived(store.identity ?? createIdentityDraft())
  const birth = $derived(parseIsoDate(identity.birthDate))
  const heroName = $derived(`${identity.firstName} ${identity.lastName}`.trim())
  const heroMeta = $derived(
    [
      identity.gender === 'female' ? m.creation_female() : m.creation_male(),
      birth ? m.selection_age({ age: ageAt(birth) }) : null,
      identity.nationality ? regionName(identity.nationality, locale.current) : null,
    ]
      .filter(Boolean)
      .join(' · '),
  )

  const identityRows = $derived<Row[]>([
    { key: 'lastName', label: m.creation_lastName(), value: identity.lastName },
    { key: 'firstName', label: m.creation_firstName(), value: identity.firstName },
    {
      key: 'gender',
      label: m.creation_gender(),
      value: identity.gender === 'female' ? m.creation_female() : m.creation_male(),
    },
    { key: 'height', label: m.creation_height(), value: `${identity.height} cm` },
    {
      key: 'nationality',
      label: m.creation_nationality(),
      value: regionName(identity.nationality, locale.current),
    },
    {
      key: 'birthDate',
      label: m.creation_birthDate(),
      value: birth ? formatDate(birth, locale.current) : '—',
    },
    { key: 'birthPlace', label: m.creation_birthPlace(), value: identity.birthPlace || '—' },
  ])

  const pedRow = $derived<Row>({
    key: 'ped',
    label: m.appearance_stepPed(),
    value: pedModel
      ? BASIC_PED_LABELS[pedModel]
        ? tr(BASIC_PED_LABELS[pedModel])
        : pedModel
      : '—',
    mono: pedModel || undefined,
  })

  const blend = (value: number): string => {
    const father = Math.round(value)
    const mother = 100 - father

    return `${mother} % ${m.appearance_ctrlMother()} · ${father} % ${m.appearance_ctrlFather()}`
  }

  const heritageRows = $derived<Row[]>([
    {
      key: 'mother',
      label: m.appearance_ctrlMother(),
      value:
        store.heritageConfig.mothers[draft[controlKey('heritage', 'parents', 'mother')] ?? 0]
          ?.name ?? '—',
    },
    {
      key: 'father',
      label: m.appearance_ctrlFather(),
      value:
        store.heritageConfig.fathers[draft[controlKey('heritage', 'parents', 'father')] ?? 0]
          ?.name ?? '—',
    },
    {
      key: 'resemblance',
      label: m.appearance_ctrlResemblance(),
      value: blend(draft[controlKey('heritage', 'resemblance', 'resemblance')] ?? 50),
    },
    {
      key: 'skinTone',
      label: m.appearance_ctrlSkinTone(),
      value: blend(draft[controlKey('heritage', 'resemblance', 'skinTone')] ?? 50),
    },
  ])

  const controlRow = (
    stepId: string,
    category: AppearanceCategory,
    control: AppearanceControl,
  ): Row => {
    const value = draft[controlKey(stepId, category.id, control.id)] ?? 0
    const row: Row = { key: `${category.id}.${control.id}`, label: tr(control.label), value: '' }

    if (control.type === 'swatches') {
      row.color = control.colors?.[value]
      row.value = String(value + 1)
    } else if (control.type === 'sprite') {
      row.value = `${value + 1} / ${control.max ?? 1}`
    } else {
      row.value =
        (control.step ?? 1) < 1
          ? value.toFixed(2)
          : control.unit
            ? `${value} ${control.unit}`
            : String(value)
    }

    return row
  }

  const sections = $derived(
    ['physical', 'clothing', 'accessories', 'tattoos'].map((stepId) => {
      const step = APPEARANCE_STEPS.find((entry) => entry.id === stepId)

      return {
        key: stepId,
        title: step ? tr(step.label) : stepId,
        categories: (step?.categories ?? []).map((category) => ({
          key: category.id,
          label: tr(category.label),
          rows: category.controls
            .filter((control) => control.type !== 'blend')
            .map((control) => controlRow(stepId, category, control)),
        })),
      }
    }),
  )
</script>

{#snippet rows(list: Row[])}
  <div class="flex flex-col gap-2">
    {#each list as row (row.key)}
      <div class="flex items-baseline justify-between gap-4">
        <span class="t-caption text-fg-tertiary">{row.label}</span>
        <span class="flex items-center gap-2 text-right">
          {#if row.color}<span class="mc-dot" style:background={row.color} aria-hidden="true"
            ></span>{/if}
          <span class="t-body-sm text-fg-primary">{row.value}</span>
          {#if row.mono}<span class="t-code text-fg-tertiary">{row.mono}</span>{/if}
        </span>
      </div>
    {/each}
  </div>
{/snippet}

<div class="flex flex-col gap-7">
  <div class="flex flex-col gap-1">
    <h2 class="t-title">{heroName || m.creation_previewEmpty()}</h2>
    <span class="t-caption uppercase tracking-wider text-fg-tertiary">{heroMeta}</span>
  </div>

  <div class="flex flex-col gap-3">
    <Divider label={m.appearance_sumIdentity()} />
    {@render rows(identityRows)}
  </div>

  <div class="flex flex-col gap-3">
    <Divider label={m.appearance_sumCharacter()} />
    {@render rows([pedRow])}
  </div>

  <div class="flex flex-col gap-3">
    <Divider label={m.appearance_stepHeritage()} />
    {@render rows(heritageRows)}
  </div>

  {#each sections as section (section.key)}
    <div class="flex flex-col gap-3">
      <Divider label={section.title} />
      <div class="flex flex-col gap-4">
        {#each section.categories as category (category.key)}
          <div class="flex flex-col gap-2">
            <span class="t-caption uppercase tracking-wider text-fg-secondary"
              >{category.label}</span
            >
            <div class="pl-3">{@render rows(category.rows)}</div>
          </div>
        {/each}
      </div>
    </div>
  {/each}
</div>
