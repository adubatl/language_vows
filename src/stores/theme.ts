import { defineStore } from 'pinia'
import { generateRandomTheme, defaultThemes } from '../utils/theme'
import type { Theme } from '../utils/theme'

export const useThemeStore = defineStore('theme', {
  state: () => ({
    currentTheme: {
      name: 'Base Theme',
      background:
        getComputedStyle(document.documentElement).getPropertyValue('--bg-color').trim() ||
        '#1a1a1a',
      text:
        getComputedStyle(document.documentElement).getPropertyValue('--text-color').trim() ||
        '#ffffff',
    } as Theme,
    baseTheme: {
      name: 'Base Theme',
      background:
        getComputedStyle(document.documentElement).getPropertyValue('--bg-color').trim() ||
        '#1a1a1a',
      text:
        getComputedStyle(document.documentElement).getPropertyValue('--text-color').trim() ||
        '#ffffff',
    } as Theme,
  }),

  actions: {
    setTheme(theme: Theme) {
      this.currentTheme = theme
      // Apply theme to document
      document.documentElement.style.setProperty('--bg-color', theme.background)
      document.documentElement.style.setProperty('--text-color', theme.text)

      // Update other related variables to maintain consistency
      document.documentElement.style.setProperty('--button-bg', theme.background)
      document.documentElement.style.setProperty(
        '--button-hover',
        theme.background === '#ffffff' ? '#f0f0f0' : '#2a2a2a',
      )
      document.documentElement.style.setProperty(
        '--border-color',
        theme.background === '#ffffff' ? '#e0e0e0' : '#333333',
      )
    },

    generateNewTheme() {
      const newTheme = generateRandomTheme()
      this.setTheme(newTheme)
    },

    resetTheme() {
      this.setTheme(this.baseTheme)
    },
  },
})
