export interface LanguageVow {
  text: string
  language: 'typescript' | 'go' | 'python'
  id: string
}

export type Language = 'typescript' | 'go' | 'python'

// Add a new type for the vows prop
export type VowsArray = LanguageVow[] | null | undefined
