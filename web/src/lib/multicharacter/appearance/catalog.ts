import type { IconName } from '@siku/ui'
import type { MessageKey } from '@/lib/i18n.svelte'

export type AppearanceControlType = 'select' | 'slider' | 'swatches' | 'blend' | 'sprite'

export interface AppearanceControl {
  id: string
  label: MessageKey
  type: AppearanceControlType
  max?: number
  min?: number
  colors?: string[]
  portrait?: boolean
  section?: MessageKey
  minLabel?: MessageKey
  maxLabel?: MessageKey
  unit?: string
  step?: number
  defaultValue?: number
  sprite?: 'eyeColour'
  spriteColumns?: number
}

export interface AppearanceCategory {
  id: string
  label: MessageKey
  icon: IconName
  group?: MessageKey
  controls: AppearanceControl[]
}

export interface AppearanceStep {
  id: string
  icon: IconName
  label: MessageKey
  subtitle: MessageKey
  categories?: AppearanceCategory[]
}

export interface PedModel {
  id: string
  label?: MessageKey
  name?: string
}

export const BASIC_PED_LABELS: Record<string, MessageKey> = {
  mp_m_freemode_01: 'appearance_pedMale',
  mp_f_freemode_01: 'appearance_pedFemale',
}

export const PED_MODELS: PedModel[] = [
  { id: 'mp_m_freemode_01', label: 'appearance_pedMale' },
  { id: 'mp_f_freemode_01', label: 'appearance_pedFemale' },
  { id: 'a_m_y_skater_01', name: 'A_M_Y_Skater_01' },
  { id: 'a_m_y_hipster_02', name: 'A_M_Y_Hipster_02' },
  { id: 'a_f_y_tourist_01', name: 'A_F_Y_Tourist_01' },
  { id: 'a_m_m_business_01', name: 'A_M_M_Business_01' },
  { id: 'a_f_y_business_02', name: 'A_F_Y_Business_02' },
  { id: 'a_m_y_beach_01', name: 'A_M_Y_Beach_01' },
  { id: 'a_f_y_fitness_02', name: 'A_F_Y_Fitness_02' },
  { id: 'a_m_m_farmer_01', name: 'A_M_M_Farmer_01' },
  { id: 'a_f_m_bodybuild_01', name: 'A_F_M_BodyBuild_01' },
  { id: 'a_m_y_golfer_01', name: 'A_M_Y_Golfer_01' },
  { id: 'a_f_y_hipster_01', name: 'A_F_Y_Hipster_01' },
  { id: 'a_m_m_skidrow_01', name: 'A_M_M_Skidrow_01' },
  { id: 'a_f_y_runner_01', name: 'A_F_Y_Runner_01' },
  { id: 'a_m_y_vinewood_03', name: 'A_M_Y_Vinewood_03' },
  { id: 's_m_y_cop_01', name: 'S_M_Y_Cop_01' },
]

const HAIR_COLORS = [
  '#1c1f21',
  '#272a2c',
  '#312e2c',
  '#35261c',
  '#4b321f',
  '#5c3b24',
  '#6d4c35',
  '#6b503b',
  '#765c45',
  '#7f684e',
  '#99815d',
  '#a79369',
  '#af9c70',
  '#bba063',
  '#d6b97b',
  '#dac38e',
  '#9f7f59',
  '#845039',
  '#682b1f',
  '#61120c',
  '#640f0a',
  '#7c140f',
  '#a02e19',
  '#b64b28',
  '#a2502f',
  '#aa4e2b',
  '#626262',
  '#808080',
  '#aaaaaa',
  '#c5c5c5',
  '#463955',
  '#5a3f6b',
  '#763c76',
  '#ed74e3',
  '#eb4b93',
  '#f299bc',
  '#04959e',
  '#025f86',
  '#023974',
  '#3fa16a',
  '#217c61',
  '#185c55',
  '#b6c034',
  '#70a90b',
  '#439d13',
  '#dcb857',
  '#e5b103',
  '#e69102',
  '#f28831',
  '#fb8057',
  '#e28b58',
  '#d1593c',
  '#ce3120',
  '#ad0903',
  '#880302',
  '#1f1814',
  '#291f19',
  '#2e221b',
  '#37291e',
  '#2e2218',
  '#231b15',
  '#020202',
  '#706c66',
  '#9d7a50',
]

const MAKEUP_COLORS = [
  '#992532',
  '#c8395d',
  '#bd516c',
  '#b8637a',
  '#a6526b',
  '#b1434c',
  '#7f3133',
  '#a4645d',
  '#c18779',
  '#cba096',
  '#c6918f',
  '#ab6f63',
  '#b06050',
  '#a84c33',
  '#b47178',
  '#ca7f92',
  '#ed9cbe',
  '#e775a4',
  '#de3e81',
  '#b34c6e',
  '#712739',
  '#4f1f2a',
  '#aa222f',
  '#de2034',
  '#cf0813',
  '#e55470',
  '#dc3fb5',
  '#c227b2',
  '#a01ca9',
  '#6e1875',
  '#731465',
  '#56165c',
  '#6d1a9d',
  '#1b3771',
  '#1d4ea7',
  '#1e74bb',
  '#21a3ce',
  '#25c2d2',
  '#23cca5',
  '#27c07d',
  '#1b9c32',
  '#148604',
  '#70d041',
  '#c5ea34',
  '#e1e32f',
  '#ffdd26',
  '#fac026',
  '#f78a27',
  '#fe5910',
  '#be6e19',
  '#f7c97f',
  '#fbe5c0',
  '#f5f5f5',
  '#b3b4b3',
  '#919191',
  '#564e4e',
  '#180e0e',
  '#58969e',
  '#4d6f8c',
  '#1a2b55',
  '#a07e6b',
  '#826355',
  '#6d5346',
  '#3e2d27',
]

const HERITAGE_CATEGORIES: AppearanceCategory[] = [
  {
    id: 'parents',
    label: 'appearance_catParents',
    icon: 'users',
    controls: [
      {
        id: 'mother',
        label: 'appearance_ctrlMother',
        type: 'select',
        portrait: true,
      },
      {
        id: 'father',
        label: 'appearance_ctrlFather',
        type: 'select',
        portrait: true,
      },
    ],
  },
  {
    id: 'resemblance',
    label: 'appearance_catResemblance',
    icon: 'dna',
    controls: [
      {
        id: 'resemblance',
        label: 'appearance_ctrlResemblance',
        type: 'blend',
        min: 0,
        max: 100,
        minLabel: 'appearance_ctrlMother',
        maxLabel: 'appearance_ctrlFather',
      },
      {
        id: 'skinTone',
        label: 'appearance_ctrlSkinTone',
        type: 'blend',
        min: 0,
        max: 100,
        minLabel: 'appearance_ctrlMother',
        maxLabel: 'appearance_ctrlFather',
      },
    ],
  },
]

const PHYSICAL_CATEGORIES: AppearanceCategory[] = [
  {
    id: 'hair',
    label: 'appearance_catHair',
    icon: 'scissors',
    group: 'appearance_groupHairiness',
    controls: [
      {
        id: 'style',
        label: 'appearance_ctrlHairstyle',
        type: 'slider',
        min: 1,
        max: 38,
        unit: '/ 38',
        defaultValue: 1,
      },
      { id: 'color', label: 'appearance_ctrlColor', type: 'swatches', colors: HAIR_COLORS },
      {
        id: 'highlights',
        label: 'appearance_ctrlHighlights',
        type: 'swatches',
        colors: HAIR_COLORS,
      },
    ],
  },
  {
    id: 'eyebrows',
    label: 'appearance_catEyebrows',
    icon: 'eyebrow',
    group: 'appearance_groupHairiness',
    controls: [
      {
        id: 'shape',
        label: 'appearance_ctrlShape',
        type: 'slider',
        min: 1,
        max: 34,
        unit: '/ 34',
        defaultValue: 1,
      },
      { id: 'color', label: 'appearance_ctrlColor', type: 'swatches', colors: HAIR_COLORS },
      {
        id: 'opacity',
        label: 'appearance_ctrlOpacity',
        type: 'slider',
        min: 0,
        max: 1,
        step: 0.05,
        defaultValue: 0.5,
        minLabel: 'appearance_poleSparse',
        maxLabel: 'appearance_poleStrong',
      },
      {
        id: 'height',
        label: 'appearance_ctrlBrowHeight',
        type: 'slider',
        min: -1,
        max: 1,
        step: 0.05,
        defaultValue: 0,
        minLabel: 'appearance_poleClose',
        maxLabel: 'appearance_poleFar',
      },
      {
        id: 'depth',
        label: 'appearance_ctrlBrowDepth',
        type: 'slider',
        min: -1,
        max: 1,
        step: 0.05,
        defaultValue: 0,
        minLabel: 'appearance_poleSunken',
        maxLabel: 'appearance_poleProminent',
      },
    ],
  },
  {
    id: 'beard',
    label: 'appearance_catBeard',
    icon: 'beard',
    group: 'appearance_groupHairiness',
    controls: [
      {
        id: 'style',
        label: 'appearance_ctrlStyle',
        type: 'slider',
        min: 1,
        max: 29,
        unit: '/ 29',
        defaultValue: 1,
      },
      { id: 'color', label: 'appearance_ctrlColor', type: 'swatches', colors: HAIR_COLORS },
      {
        id: 'opacity',
        label: 'appearance_ctrlOpacity',
        type: 'slider',
        min: 0,
        max: 1,
        step: 0.05,
        defaultValue: 0.5,
        minLabel: 'appearance_poleSparse',
        maxLabel: 'appearance_poleStrong',
      },
    ],
  },
  {
    id: 'chestHair',
    label: 'appearance_catChestHair',
    icon: 'waves',
    group: 'appearance_groupHairiness',
    controls: [
      {
        id: 'style',
        label: 'appearance_ctrlStyle',
        type: 'slider',
        min: 1,
        max: 17,
        unit: '/ 17',
        defaultValue: 1,
      },
      { id: 'color', label: 'appearance_ctrlColor', type: 'swatches', colors: HAIR_COLORS },
      {
        id: 'opacity',
        label: 'appearance_ctrlOpacity',
        type: 'slider',
        min: 0,
        max: 1,
        step: 0.05,
        defaultValue: 0.5,
        minLabel: 'appearance_poleSparse',
        maxLabel: 'appearance_poleHairy',
      },
    ],
  },
  {
    id: 'eyes',
    label: 'appearance_catEyes',
    icon: 'eye',
    group: 'appearance_groupFace',
    controls: [
      {
        id: 'opening',
        label: 'appearance_ctrlOpening',
        type: 'slider',
        min: -1,
        max: 1,
        step: 0.05,
        defaultValue: 0,
        minLabel: 'appearance_poleNarrow',
        maxLabel: 'appearance_poleWide',
      },
      {
        id: 'style',
        label: 'appearance_ctrlEyeStyle',
        type: 'sprite',
        sprite: 'eyeColour',
        max: 32,
        spriteColumns: 8,
      },
    ],
  },
  {
    id: 'nose',
    label: 'appearance_catNose',
    icon: 'nose',
    group: 'appearance_groupFace',
    controls: [
      {
        id: 'width',
        label: 'appearance_ctrlNoseWidth',
        type: 'slider',
        min: -1,
        max: 1,
        step: 0.05,
        defaultValue: 0,
        minLabel: 'appearance_poleNarrow',
        maxLabel: 'appearance_poleWide',
      },
      {
        id: 'height',
        label: 'appearance_ctrlNoseHeight',
        type: 'slider',
        min: -1,
        max: 1,
        step: 0.05,
        defaultValue: 0,
        minLabel: 'appearance_poleLow',
        maxLabel: 'appearance_poleHigh',
      },
      {
        id: 'length',
        label: 'appearance_ctrlNoseLength',
        type: 'slider',
        min: -1,
        max: 1,
        step: 0.05,
        defaultValue: 0,
        minLabel: 'appearance_poleShort',
        maxLabel: 'appearance_poleLong',
      },
      {
        id: 'bridgeHeight',
        label: 'appearance_ctrlNoseBridgeHeight',
        type: 'slider',
        min: -1,
        max: 1,
        step: 0.05,
        defaultValue: 0,
        minLabel: 'appearance_poleLow',
        maxLabel: 'appearance_poleHigh',
      },
      {
        id: 'bridgeTwist',
        label: 'appearance_ctrlNoseBridgeTwist',
        type: 'slider',
        min: -1,
        max: 1,
        step: 0.05,
        defaultValue: 0,
        minLabel: 'appearance_poleLeft',
        maxLabel: 'appearance_poleRight',
      },
      {
        id: 'tipHeight',
        label: 'appearance_ctrlNoseTipHeight',
        type: 'slider',
        min: -1,
        max: 1,
        step: 0.05,
        defaultValue: 0,
        minLabel: 'appearance_poleLow',
        maxLabel: 'appearance_poleHigh',
      },
    ],
  },
  {
    id: 'cheeks',
    label: 'appearance_catCheeks',
    icon: 'smile',
    group: 'appearance_groupFace',
    controls: [
      {
        id: 'boneHeight',
        label: 'appearance_ctrlCheekboneHeight',
        type: 'slider',
        min: -1,
        max: 1,
        step: 0.05,
        defaultValue: 0,
        minLabel: 'appearance_poleLow',
        maxLabel: 'appearance_poleHigh',
      },
      {
        id: 'boneWidth',
        label: 'appearance_ctrlCheekboneWidth',
        type: 'slider',
        min: -1,
        max: 1,
        step: 0.05,
        defaultValue: 0,
        minLabel: 'appearance_poleNarrow',
        maxLabel: 'appearance_poleWide',
      },
      {
        id: 'width',
        label: 'appearance_ctrlCheekWidth',
        type: 'slider',
        min: -1,
        max: 1,
        step: 0.05,
        defaultValue: 0,
        minLabel: 'appearance_poleGaunt',
        maxLabel: 'appearance_polePuffy',
      },
    ],
  },
  {
    id: 'lips',
    label: 'appearance_catLips',
    icon: 'lips',
    group: 'appearance_groupFace',
    controls: [
      {
        id: 'thickness',
        label: 'appearance_ctrlLipThickness',
        type: 'slider',
        min: -1,
        max: 1,
        step: 0.05,
        defaultValue: 0,
        minLabel: 'appearance_poleThin',
        maxLabel: 'appearance_poleThick',
      },
    ],
  },
  {
    id: 'jaw',
    label: 'appearance_catJaw',
    icon: 'jaw',
    group: 'appearance_groupFace',
    controls: [
      {
        id: 'width',
        label: 'appearance_ctrlJawWidth',
        type: 'slider',
        min: -1,
        max: 1,
        step: 0.05,
        defaultValue: 0,
        minLabel: 'appearance_poleNarrow',
        maxLabel: 'appearance_poleWide',
      },
      {
        id: 'length',
        label: 'appearance_ctrlJawLength',
        type: 'slider',
        min: -1,
        max: 1,
        step: 0.05,
        defaultValue: 0,
        minLabel: 'appearance_poleShort',
        maxLabel: 'appearance_poleLong',
      },
    ],
  },
  {
    id: 'chin',
    label: 'appearance_catChin',
    icon: 'chin',
    group: 'appearance_groupFace',
    controls: [
      {
        id: 'position',
        label: 'appearance_ctrlChinPosition',
        type: 'slider',
        min: -1,
        max: 1,
        step: 0.05,
        defaultValue: 0,
        minLabel: 'appearance_poleLowered',
        maxLabel: 'appearance_poleRaised',
      },
      {
        id: 'length',
        label: 'appearance_ctrlChinLength',
        type: 'slider',
        min: -1,
        max: 1,
        step: 0.05,
        defaultValue: 0,
        minLabel: 'appearance_poleShort',
        maxLabel: 'appearance_poleLong',
      },
      {
        id: 'width',
        label: 'appearance_ctrlChinWidth',
        type: 'slider',
        min: -1,
        max: 1,
        step: 0.05,
        defaultValue: 0,
        minLabel: 'appearance_poleNarrow',
        maxLabel: 'appearance_poleWide',
      },
      {
        id: 'hollow',
        label: 'appearance_ctrlChinHollow',
        type: 'slider',
        min: -1,
        max: 1,
        step: 0.05,
        defaultValue: 0,
        minLabel: 'appearance_poleSmooth',
        maxLabel: 'appearance_poleProminent',
      },
    ],
  },
  {
    id: 'neck',
    label: 'appearance_catNeck',
    icon: 'tie',
    group: 'appearance_groupFace',
    controls: [
      {
        id: 'thickness',
        label: 'appearance_ctrlNeckThickness',
        type: 'slider',
        min: -1,
        max: 1,
        step: 0.05,
        defaultValue: 0,
        minLabel: 'appearance_poleThin',
        maxLabel: 'appearance_poleThick',
      },
    ],
  },
  {
    id: 'ageing',
    label: 'appearance_catAgeing',
    icon: 'clock',
    group: 'appearance_groupSkin',
    controls: [
      {
        id: 'style',
        label: 'appearance_ctrlAgeingType',
        type: 'slider',
        min: 1,
        max: 15,
        unit: '/ 15',
        defaultValue: 1,
      },
      {
        id: 'opacity',
        label: 'appearance_ctrlOpacity',
        type: 'slider',
        min: 0,
        max: 1,
        step: 0.05,
        defaultValue: 0.5,
        minLabel: 'appearance_poleSubtle',
        maxLabel: 'appearance_poleProminent',
      },
    ],
  },
  {
    id: 'makeup',
    label: 'appearance_catMakeup',
    icon: 'brush',
    group: 'appearance_groupSkin',
    controls: [
      {
        id: 'lipstickStyle',
        section: 'appearance_secLipstick',
        label: 'appearance_ctrlStyle',
        type: 'slider',
        min: 1,
        max: 10,
        unit: '/ 10',
        defaultValue: 1,
      },
      {
        id: 'lipstickColor',
        label: 'appearance_ctrlColor',
        type: 'swatches',
        colors: MAKEUP_COLORS,
      },
      {
        id: 'lipstickOpacity',
        label: 'appearance_ctrlOpacity',
        type: 'slider',
        min: 0,
        max: 1,
        step: 0.05,
        defaultValue: 0.5,
        minLabel: 'appearance_poleSubtle',
        maxLabel: 'appearance_poleProminent',
      },
      {
        id: 'makeupStyle',
        section: 'appearance_secMakeup',
        label: 'appearance_ctrlStyle',
        type: 'slider',
        min: 1,
        max: 75,
        unit: '/ 75',
        defaultValue: 1,
      },
      {
        id: 'makeupPrimaryColor',
        label: 'appearance_ctrlPrimaryColor',
        type: 'swatches',
        colors: MAKEUP_COLORS,
      },
      {
        id: 'makeupSecondaryColor',
        label: 'appearance_ctrlSecondaryColor',
        type: 'swatches',
        colors: MAKEUP_COLORS,
      },
      {
        id: 'makeupOpacity',
        label: 'appearance_ctrlOpacity',
        type: 'slider',
        min: 0,
        max: 1,
        step: 0.05,
        defaultValue: 0.5,
        minLabel: 'appearance_poleSubtle',
        maxLabel: 'appearance_poleProminent',
      },
      {
        id: 'blushStyle',
        section: 'appearance_secBlush',
        label: 'appearance_ctrlStyle',
        type: 'slider',
        min: 1,
        max: 7,
        unit: '/ 7',
        defaultValue: 1,
      },
      {
        id: 'blushColor',
        label: 'appearance_ctrlColor',
        type: 'swatches',
        colors: MAKEUP_COLORS,
      },
      {
        id: 'blushOpacity',
        label: 'appearance_ctrlOpacity',
        type: 'slider',
        min: 0,
        max: 1,
        step: 0.05,
        defaultValue: 0.5,
        minLabel: 'appearance_poleSubtle',
        maxLabel: 'appearance_poleProminent',
      },
    ],
  },
  {
    id: 'skinDamage',
    label: 'appearance_catSkinDamage',
    icon: 'sun',
    group: 'appearance_groupSkin',
    controls: [
      {
        id: 'sunDamageStyle',
        section: 'appearance_secSunDamage',
        label: 'appearance_ctrlSunDamageType',
        type: 'slider',
        min: 1,
        max: 11,
        unit: '/ 11',
        defaultValue: 1,
      },
      {
        id: 'sunDamageOpacity',
        label: 'appearance_ctrlOpacity',
        type: 'slider',
        min: 0,
        max: 1,
        step: 0.05,
        defaultValue: 0.5,
        minLabel: 'appearance_poleSubtle',
        maxLabel: 'appearance_poleProminent',
      },
      {
        id: 'molesStyle',
        section: 'appearance_secMoles',
        label: 'appearance_ctrlMoleType',
        type: 'slider',
        min: 1,
        max: 18,
        unit: '/ 18',
        defaultValue: 1,
      },
      {
        id: 'molesOpacity',
        label: 'appearance_ctrlOpacity',
        type: 'slider',
        min: 0,
        max: 1,
        step: 0.05,
        defaultValue: 0.5,
        minLabel: 'appearance_poleSubtle',
        maxLabel: 'appearance_poleProminent',
      },
      {
        id: 'blemishesStyle',
        section: 'appearance_secBlemishes',
        label: 'appearance_ctrlBlemishType',
        type: 'slider',
        min: 1,
        max: 24,
        unit: '/ 24',
        defaultValue: 1,
      },
      {
        id: 'blemishesOpacity',
        label: 'appearance_ctrlOpacity',
        type: 'slider',
        min: 0,
        max: 1,
        step: 0.05,
        defaultValue: 0.5,
        minLabel: 'appearance_poleSubtle',
        maxLabel: 'appearance_poleProminent',
      },
    ],
  },
]

const CLOTHING_CATEGORIES: AppearanceCategory[] = [
  {
    id: 'jacket',
    label: 'appearance_catJacket',
    icon: 'hanger',
    controls: [
      {
        id: 'model',
        label: 'appearance_ctrlJacketStyle',
        type: 'slider',
        min: 1,
        max: 61,
        unit: '/ 61',
        defaultValue: 1,
      },
      {
        id: 'variant',
        label: 'appearance_ctrlJacketVariant',
        type: 'slider',
        min: 1,
        max: 8,
        unit: '/ 8',
        defaultValue: 1,
      },
    ],
  },
  {
    id: 'tshirt',
    label: 'appearance_catTshirt',
    icon: 'shirt',
    controls: [
      {
        id: 'model',
        label: 'appearance_ctrlTshirtStyle',
        type: 'slider',
        min: 1,
        max: 111,
        unit: '/ 111',
        defaultValue: 1,
      },
      {
        id: 'variant',
        label: 'appearance_ctrlTshirtVariant',
        type: 'slider',
        min: 1,
        max: 12,
        unit: '/ 12',
        defaultValue: 1,
      },
    ],
  },
  {
    id: 'armsGloves',
    label: 'appearance_catArmsGloves',
    icon: 'arm',
    controls: [
      {
        id: 'model',
        label: 'appearance_ctrlArmsStyle',
        type: 'slider',
        min: 1,
        max: 17,
        unit: '/ 17',
        defaultValue: 1,
      },
      {
        id: 'variant',
        label: 'appearance_ctrlArmsVariant',
        type: 'slider',
        min: 1,
        max: 6,
        unit: '/ 6',
        defaultValue: 1,
      },
    ],
  },
  {
    id: 'pants',
    label: 'appearance_catPants',
    icon: 'pants',
    controls: [
      {
        id: 'model',
        label: 'appearance_ctrlPantsStyle',
        type: 'slider',
        min: 1,
        max: 98,
        unit: '/ 98',
        defaultValue: 1,
      },
      {
        id: 'variant',
        label: 'appearance_ctrlPantsVariant',
        type: 'slider',
        min: 1,
        max: 10,
        unit: '/ 10',
        defaultValue: 1,
      },
    ],
  },
  {
    id: 'shoes',
    label: 'appearance_catShoes',
    icon: 'shoe',
    controls: [
      {
        id: 'model',
        label: 'appearance_ctrlShoesStyle',
        type: 'slider',
        min: 1,
        max: 77,
        unit: '/ 77',
        defaultValue: 1,
      },
      {
        id: 'variant',
        label: 'appearance_ctrlShoesVariant',
        type: 'slider',
        min: 1,
        max: 10,
        unit: '/ 10',
        defaultValue: 1,
      },
    ],
  },
]

const ACCESSORY_CATEGORIES: AppearanceCategory[] = [
  {
    id: 'mask',
    label: 'appearance_catMask',
    icon: 'mask',
    controls: [
      {
        id: 'model',
        label: 'appearance_ctrlMaskStyle',
        type: 'slider',
        min: 1,
        max: 53,
        unit: '/ 53',
        defaultValue: 1,
      },
      {
        id: 'variant',
        label: 'appearance_ctrlMaskVariant',
        type: 'slider',
        min: 1,
        max: 8,
        unit: '/ 8',
        defaultValue: 1,
      },
    ],
  },
  {
    id: 'backpack',
    label: 'appearance_catBackpack',
    icon: 'bag',
    controls: [
      {
        id: 'model',
        label: 'appearance_ctrlBackpackStyle',
        type: 'slider',
        min: 1,
        max: 40,
        unit: '/ 40',
        defaultValue: 1,
      },
      {
        id: 'variant',
        label: 'appearance_ctrlBackpackVariant',
        type: 'slider',
        min: 1,
        max: 6,
        unit: '/ 6',
        defaultValue: 1,
      },
    ],
  },
  {
    id: 'hat',
    label: 'appearance_catHat',
    icon: 'hat',
    controls: [
      {
        id: 'model',
        label: 'appearance_ctrlHatStyle',
        type: 'slider',
        min: 1,
        max: 91,
        unit: '/ 91',
        defaultValue: 1,
      },
      {
        id: 'variant',
        label: 'appearance_ctrlHatVariant',
        type: 'slider',
        min: 1,
        max: 8,
        unit: '/ 8',
        defaultValue: 1,
      },
    ],
  },
  {
    id: 'glasses',
    label: 'appearance_catGlasses',
    icon: 'glasses',
    controls: [
      {
        id: 'model',
        label: 'appearance_ctrlGlassesStyle',
        type: 'slider',
        min: 1,
        max: 41,
        unit: '/ 41',
        defaultValue: 1,
      },
      {
        id: 'variant',
        label: 'appearance_ctrlGlassesVariant',
        type: 'slider',
        min: 1,
        max: 10,
        unit: '/ 10',
        defaultValue: 1,
      },
    ],
  },
  {
    id: 'earrings',
    label: 'appearance_catEarrings',
    icon: 'ear',
    controls: [
      {
        id: 'model',
        label: 'appearance_ctrlEarringsStyle',
        type: 'slider',
        min: 1,
        max: 31,
        unit: '/ 31',
        defaultValue: 1,
      },
      {
        id: 'variant',
        label: 'appearance_ctrlEarringsVariant',
        type: 'slider',
        min: 1,
        max: 4,
        unit: '/ 4',
        defaultValue: 1,
      },
    ],
  },
  {
    id: 'watch',
    label: 'appearance_catWatch',
    icon: 'watch',
    controls: [
      {
        id: 'model',
        label: 'appearance_ctrlWatchStyle',
        type: 'slider',
        min: 1,
        max: 27,
        unit: '/ 27',
        defaultValue: 1,
      },
      {
        id: 'variant',
        label: 'appearance_ctrlWatchVariant',
        type: 'slider',
        min: 1,
        max: 6,
        unit: '/ 6',
        defaultValue: 1,
      },
    ],
  },
  {
    id: 'bracelet',
    label: 'appearance_catBracelet',
    icon: 'ring',
    controls: [
      {
        id: 'model',
        label: 'appearance_ctrlBraceletStyle',
        type: 'slider',
        min: 1,
        max: 19,
        unit: '/ 19',
        defaultValue: 1,
      },
      {
        id: 'variant',
        label: 'appearance_ctrlBraceletVariant',
        type: 'slider',
        min: 1,
        max: 4,
        unit: '/ 4',
        defaultValue: 1,
      },
    ],
  },
  {
    id: 'neckwear',
    label: 'appearance_catNeckwear',
    icon: 'necklace',
    controls: [
      {
        id: 'model',
        label: 'appearance_ctrlNeckwearStyle',
        type: 'slider',
        min: 1,
        max: 43,
        unit: '/ 43',
        defaultValue: 1,
      },
      {
        id: 'variant',
        label: 'appearance_ctrlNeckwearVariant',
        type: 'slider',
        min: 1,
        max: 6,
        unit: '/ 6',
        defaultValue: 1,
      },
    ],
  },
]

const TATTOO_ZONES: { id: string; label: MessageKey; icon: IconName }[] = [
  { id: 'hair', label: 'appearance_catHair', icon: 'scissors' },
  { id: 'head', label: 'appearance_catHead', icon: 'head' },
  { id: 'neck', label: 'appearance_catNeck', icon: 'tie' },
  { id: 'torso', label: 'appearance_catTorso', icon: 'shirt' },
  { id: 'back', label: 'appearance_catBack', icon: 'back' },
  { id: 'leftArm', label: 'appearance_catLeftArm', icon: 'arm' },
  { id: 'rightArm', label: 'appearance_catRightArm', icon: 'arm' },
  { id: 'leftLeg', label: 'appearance_catLeftLeg', icon: 'leg' },
  { id: 'rightLeg', label: 'appearance_catRightLeg', icon: 'leg' },
]

const TATTOO_CATEGORIES: AppearanceCategory[] = TATTOO_ZONES.map((zone) => ({
  id: zone.id,
  label: zone.label,
  icon: zone.icon,
  controls: [
    {
      id: 'tattoo',
      label: 'appearance_ctrlTattoo',
      type: 'slider',
      min: 1,
      max: 21,
      unit: '/ 21',
      defaultValue: 1,
    },
  ],
}))

export const APPEARANCE_STEPS: AppearanceStep[] = [
  {
    id: 'ped',
    icon: 'user',
    label: 'appearance_stepPed',
    subtitle: 'appearance_stepPedSubtitle',
  },
  {
    id: 'heritage',
    icon: 'dna',
    label: 'appearance_stepHeritage',
    subtitle: 'appearance_stepHeritageSubtitle',
    categories: HERITAGE_CATEGORIES,
  },
  {
    id: 'physical',
    icon: 'face',
    label: 'appearance_stepPhysical',
    subtitle: 'appearance_stepPhysicalSubtitle',
    categories: PHYSICAL_CATEGORIES,
  },
  {
    id: 'clothing',
    icon: 'shirt',
    label: 'appearance_stepClothing',
    subtitle: 'appearance_stepClothingSubtitle',
    categories: CLOTHING_CATEGORIES,
  },
  {
    id: 'accessories',
    icon: 'glasses',
    label: 'appearance_stepAccessories',
    subtitle: 'appearance_stepAccessoriesSubtitle',
    categories: ACCESSORY_CATEGORIES,
  },
  {
    id: 'tattoos',
    icon: 'pen',
    label: 'appearance_stepTattoos',
    subtitle: 'appearance_stepTattoosSubtitle',
    categories: TATTOO_CATEGORIES,
  },
  {
    id: 'summary',
    icon: 'clipboard',
    label: 'appearance_stepSummary',
    subtitle: 'appearance_stepSummarySubtitle',
  },
]

export const controlKey = (stepId: string, categoryId: string, controlId: string): string =>
  `${stepId}.${categoryId}.${controlId}`

export const CLOTHING_IDS = CLOTHING_CATEGORIES.map((category) => category.id)
export const ACCESSORY_IDS = ACCESSORY_CATEGORIES.map((category) => category.id)
export const TATTOO_ZONE_IDS = TATTOO_ZONES.map((zone) => zone.id)

export const stepById = (id: string): AppearanceStep | undefined =>
  APPEARANCE_STEPS.find((step) => step.id === id)

const PHYSICAL_LIMITS: Record<string, string> = {
  'hair.style': 'hairStyles',
  'eyebrows.shape': 'eyebrows',
  'beard.style': 'beard',
  'chestHair.style': 'chestHair',
  'ageing.style': 'ageing',
  'makeup.lipstickStyle': 'lipstick',
  'makeup.makeupStyle': 'makeup',
  'makeup.blushStyle': 'blush',
  'skinDamage.sunDamageStyle': 'sunDamage',
  'skinDamage.molesStyle': 'moles',
  'skinDamage.blemishesStyle': 'blemishes',
}

export const limitKeyFor = (
  stepId: string,
  categoryId: string,
  controlId: string,
): string | undefined => {
  if (stepId === 'clothing' || stepId === 'accessories') {
    return controlId === 'model'
      ? `${categoryId}Model`
      : controlId === 'variant'
        ? `${categoryId}Variant`
        : undefined
  }

  if (stepId === 'tattoos') {
    return controlId === 'tattoo' ? `${categoryId}Tattoo` : undefined
  }

  if (stepId === 'physical') {
    return PHYSICAL_LIMITS[`${categoryId}.${controlId}`]
  }

  return undefined
}

export const createAppearanceDraft = (): Record<string, number> => {
  const draft: Record<string, number> = {}

  for (const step of APPEARANCE_STEPS) {
    for (const category of step.categories ?? []) {
      for (const control of category.controls) {
        if (control.defaultValue !== undefined) {
          draft[controlKey(step.id, category.id, control.id)] = control.defaultValue
        } else if (control.type === 'slider' || control.type === 'blend') {
          draft[controlKey(step.id, category.id, control.id)] = Math.round(
            ((control.min ?? 0) + (control.max ?? 100)) / 2,
          )
        } else {
          draft[controlKey(step.id, category.id, control.id)] = 0
        }
      }
    }
  }

  return draft
}
