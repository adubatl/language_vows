export interface LanguageVow {
  text: string
  language: 'typescript' | 'go' | 'python'
  id: string
}

export type Language = 'typescript' | 'go' | 'python'

// Add a new type for the vows prop
export type VowsArray = LanguageVow[] | null | undefined

// Add the Transaction type
export interface Transaction {
  operation: 'CREATE' | 'READ' | 'UPDATE' | 'DELETE'
  timestamp: number
  language?: Language
  text: string
}
