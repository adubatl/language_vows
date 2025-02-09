interface Theme {
  name: string
  background: string
  text: string
  accent: string
}

// Helper function to calculate relative luminance
function getLuminance(r: number, g: number, b: number): number {
  const [rs, gs, bs] = [r, g, b].map((c) => {
    c = c / 255
    return c <= 0.03928 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4)
  })
  return 0.2126 * rs + 0.7152 * gs + 0.0722 * bs
}

// Calculate contrast ratio between two colors
function getContrastRatio(l1: number, l2: number): number {
  const lighter = Math.max(l1, l2)
  const darker = Math.min(l1, l2)
  return (lighter + 0.05) / (darker + 0.05)
}

// Convert hex to RGB
function hexToRgb(hex: string): number[] {
  const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex)
  return result
    ? [parseInt(result[1], 16), parseInt(result[2], 16), parseInt(result[3], 16)]
    : [0, 0, 0]
}

// Generate a random hex color
function randomColor(): string {
  return (
    '#' +
    Math.floor(Math.random() * 16777215)
      .toString(16)
      .padStart(6, '0')
  )
}

// Generate an accessible color pair
function generateAccessibleColors(): [string, string] {
  const backgroundColor = randomColor()
  let textColor: string
  let contrastRatio = 0

  // Keep trying until we get a good contrast ratio (WCAG AA requires 4.5:1)
  while (contrastRatio < 4.5) {
    textColor = randomColor()
    const bgLuminance = getLuminance(...hexToRgb(backgroundColor))
    const textLuminance = getLuminance(...hexToRgb(textColor))
    contrastRatio = getContrastRatio(bgLuminance, textLuminance)
  }

  return [backgroundColor, textColor]
}

// List of adjectives and nouns for theme names
const adjectives = [
  'Mystic',
  'Cosmic',
  'Serene',
  'Vibrant',
  'Dreamy',
  'Electric',
  'Peaceful',
  'Dynamic',
]
const nouns = ['Dawn', 'Dusk', 'Forest', 'Ocean', 'Galaxy', 'Mountain', 'Desert', 'Storm']

export function generateRandomTheme(): Theme {
  const [bg, text] = generateAccessibleColors()
  // Generate a random accent color that contrasts with the background
  let accent = randomColor()
  let contrastRatio = 0
  while (contrastRatio < 3) {
    // Using a lower contrast ratio for accent (3:1 instead of 4.5:1)
    accent = randomColor()
    const bgLuminance = getLuminance(...hexToRgb(bg))
    const accentLuminance = getLuminance(...hexToRgb(accent))
    contrastRatio = getContrastRatio(bgLuminance, accentLuminance)
  }

  const name = `${adjectives[Math.floor(Math.random() * adjectives.length)]} ${
    nouns[Math.floor(Math.random() * nouns.length)]
  }`

  return {
    name,
    background: bg,
    text: text,
    accent: accent,
  }
}

// Some preset themes that we know are accessible
export const defaultThemes: Theme[] = [
  {
    name: 'Base Theme',
    background: 'var(--bg-color)', // Your current background color
    text: 'var(--text-color)', // Your current text color
    accent: 'var(--accent-color)',
  },
]
