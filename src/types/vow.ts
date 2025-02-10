export interface LanguageVow {
  text: string
  language: 'typescript' | 'go' | 'python'
  id: string
}

export type Language = 'typescript' | 'go' | 'python'

export type VowsArray = LanguageVow[] | null | undefined

export interface Transaction {
  operation: 'CREATE' | 'READ' | 'UPDATE' | 'DELETE'
  timestamp: number
  language: Language
  text: string
}
