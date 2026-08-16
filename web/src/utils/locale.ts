import { i18n } from '@/i18n'

export interface LocalePayload {
  language: string
  translations: Record<string, unknown>
}

export const isLocalePayload = (value: unknown): value is LocalePayload => {
  if (!value || typeof value !== 'object') {
    return false
  }
  const payload = value as Partial<LocalePayload>
  return typeof payload.language === 'string' && typeof payload.translations === 'object'
}

export const applyLocale = (payload: LocalePayload): void => {
  const web = payload.translations.web
  if (!web || typeof web !== 'object') {
    return
  }
  i18n.global.setLocaleMessage(payload.language, web as Record<string, string>)
  i18n.global.locale.value = payload.language
}
