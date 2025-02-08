import type { LanguageVow } from '@/types/vow'

const createVow = (text: string, language: LanguageVow['language']): LanguageVow => ({
  text,
  language,
  id: `${language}-${Math.random().toString(36).substr(2, 9)}`,
})

export const TYPESCRIPT_VOWS: LanguageVow[] = [
  "I solemnly swear to never use 'any' as a type escape hatch",
  'I shall maintain strict nullchecks, so help me TypeScript',
  'I vow to banish snake_case from my TypeScript kingdom forever',
  'I pledge to always define return types for public functions',
  "I shall never let implicit 'any' darken my codebase",
  'I vow to use discriminated unions instead of type casting',
  'I solemnly swear to keep my interfaces small and focused',
  'I pledge to use readonly arrays when immutability is sacred',
  'I shall embrace type inference, but never abuse it',
  'I vow to properly type my async functions with Promise<T>',
].map((text) => createVow(text, 'typescript'))

export const GO_VOWS: LanguageVow[] = [
  'I solemnly swear to handle all errors explicitly',
  'I vow to never use panic() in production code',
  'I pledge to keep my interfaces small and composable',
  'I shall always use gofmt to format my code',
  "I vow to never ignore the context package's wisdom",
  'I solemnly swear to write meaningful godoc comments',
  'I pledge to use channels for communication, not sharing state',
  "I shall embrace the simplicity of Go's type system",
  'I vow to never use global variables in my packages',
  'I solemnly swear to follow the Go proverbs in all my code',
].map((text) => createVow(text, 'go'))

export const PYTHON_VOWS: LanguageVow[] = [
  'I solemnly swear to use type hints in all new code',
  'I vow to never use from module import *',
  'I pledge to follow PEP 8 with unwavering dedication',
  'I shall always use virtual environments for my projects',
  'I vow to write docstrings that future generations will cherish',
  'I solemnly swear to never use mutable default arguments',
  'I pledge to handle exceptions with grace and specificity',
  'I shall embrace list comprehensions, but not abuse them',
  'I vow to use meaningful variable names, not x, y, or z',
  'I solemnly swear to never mix tabs and spaces',
].map((text) => createVow(text, 'python'))

export const ALL_VOWS: LanguageVow[] = [...TYPESCRIPT_VOWS, ...GO_VOWS, ...PYTHON_VOWS]
