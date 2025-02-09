import { defineStore } from 'pinia'
import { generateRandomTheme } from '../utils/theme'
import type { Theme } from '@/types'

function hexToRgb(hex: string): [number, number, number] {
  const cleanHex = hex.replace('#', '')
  const r = parseInt(cleanHex.slice(0, 2), 16)
  const g = parseInt(cleanHex.slice(2, 4), 16)
  const b = parseInt(cleanHex.slice(4, 6), 16)
  return [r, g, b]
}

function getLuminance(r: number, g: number, b: number): number {
  // Convert RGB to relative luminance using the formula from WCAG 2.0
  const [rr, gg, bb] = [r, g, b].map((c) => {
    const s = c / 255
    return s <= 0.03928 ? s / 12.92 : Math.pow((s + 0.055) / 1.055, 2.4)
  })
  return 0.2126 * rr + 0.7152 * gg + 0.0722 * bb
}

function adjustColor(color: string, amount: number): string {
  // Convert hex to RGB
  const hex = color.replace('#', '')
  const r = parseInt(hex.slice(0, 2), 16)
  const g = parseInt(hex.slice(2, 4), 16)
  const b = parseInt(hex.slice(4, 6), 16)

  // Darken each component
  const newR = Math.max(0, Math.min(255, r + amount))
  const newG = Math.max(0, Math.min(255, g + amount))
  const newB = Math.max(0, Math.min(255, b + amount))

  // Convert back to hex
  return `#${newR.toString(16).padStart(2, '0')}${newG.toString(16).padStart(2, '0')}${newB.toString(16).padStart(2, '0')}`
}

export const useThemeStore = defineStore('theme', {
  state: () => ({
    currentTheme: {
      name: 'Base Theme',
      description: 'A base theme with a light background and dark text',
      background:
        getComputedStyle(document.documentElement).getPropertyValue('--bg-color').trim() ||
        '#1a1a1a',
      text:
        getComputedStyle(document.documentElement).getPropertyValue('--text-color').trim() ||
        '#ffffff',
      accent:
        getComputedStyle(document.documentElement).getPropertyValue('--icon-color').trim() ||
        '#93cf85',
    } as Theme,
    baseTheme: {
      name: 'Base Theme',
      description: 'A base theme with a light background and dark text',
      background:
        getComputedStyle(document.documentElement).getPropertyValue('--bg-color').trim() ||
        '#1a1a1a',
      text:
        getComputedStyle(document.documentElement).getPropertyValue('--text-color').trim() ||
        '#ffffff',
      accent:
        getComputedStyle(document.documentElement).getPropertyValue('--icon-color').trim() ||
        '#93cf85',
    } as Theme,
    isGenerating: false,
  }),

  actions: {
    setTheme(theme: Theme) {
      this.currentTheme = theme
      // Apply theme to document
      document.documentElement.style.setProperty('--bg-color', theme.background)
      document.documentElement.style.setProperty('--text-color', theme.text)
      document.documentElement.style.setProperty('--accent-color', theme.accent)

      // Calculate and set hover color (darken for light backgrounds, lighten for dark ones)
      const isLightBackground = getLuminance(...hexToRgb(theme.background)) > 0.5
      const hoverColor = adjustColor(theme.background, isLightBackground ? -16 : 16)

      // Update other related variables
      document.documentElement.style.setProperty('--button-bg', theme.background)
      document.documentElement.style.setProperty('--button-hover', hoverColor)

      // Use text color with opacity for borders and dividers
      document.documentElement.style.setProperty('--border-color', `${theme.text}33`) // 20% opacity
      document.documentElement.style.setProperty('--divider-color', `${theme.text}1a`) // 10% opacity

      document.documentElement.style.setProperty(
        '--code-bg',
        isLightBackground ? adjustColor(theme.background, -8) : adjustColor(theme.background, 8),
      )
    },

    generateNewTheme() {
      const newTheme = generateRandomTheme()
      this.setTheme(newTheme)
    },

    resetTheme() {
      this.setTheme(this.baseTheme)
    },

    async generateAITheme(prompt?: string) {
      console.log(
        `Starting AI generation, setting isGenerating to true ${new Date().toISOString()}`,
      )
      this.isGenerating = true
      try {
        const response = await fetch('http://localhost:8080/api/themes/generate', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ prompt: prompt || 'Generate a unique theme' }),
        })

        if (!response.ok) {
          throw new Error('Failed to generate AI theme')
        }

        const aiTheme = await response.json()
        this.setTheme(aiTheme)
      } catch (error) {
        console.error('Error generating AI theme:', error)
        this.generateNewTheme()
      } finally {
        console.log(
          `Finishing AI generation, setting isGenerating to false ${new Date().toISOString()}`,
        )
        this.isGenerating = false
      }
    },
  },
})
