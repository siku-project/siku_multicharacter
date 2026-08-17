import axios from 'axios'
import type { AxiosInstance } from 'axios'

const resourceName: string =
  (
    (window as unknown as Record<string, unknown>).GetParentResourceName as
      (() => string) | undefined
  )?.() ?? 'siku_multicharacter'

const nui: AxiosInstance = axios.create({
  baseURL: `https://${resourceName}`,
  timeout: 5000,
  headers: {
    'Content-Type': 'application/json',
  },
})

export async function sendNuiCallback<T = unknown, R = unknown>(
  eventName: string,
  data?: T,
): Promise<R | null> {
  try {
    const response = await nui.post<R>(eventName, data ?? {})
    return response.data
  } catch {
    return null
  }
}
