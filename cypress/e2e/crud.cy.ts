import type { Language } from '../../src/types/vow'

describe('CRUD Operations', () => {
  const languages: Language[] = ['typescript', 'go', 'python']

  beforeEach(() => {
    cy.visit('/')
    cy.get('[data-test="code-output"]').should('be.visible')
    cy.get('[data-test="vow-select-disabled"]').should('have.length', 3)
  })

  languages.forEach((language) => {
    describe(`${language} vows`, () => {
      it(`should perform full CRUD cycle for ${language}`, () => {
        cy.get(`[data-test="create-${language}-button"]`).click()
        cy.wait(500)

        cy.get('[data-test="code-output"] .output-line').should('have.length', 1)
        cy.get(`[data-test="output-line-${language}"]`).should('have.length', 1)

        cy.get('[data-test="vow-select-active"]').should('have.length', 3)

        cy.get('[data-test="vow-select-active"]').first().click()
        cy.get(`[data-test="vow-option-${language}"]`).click()
        cy.contains('button', 'Read Vow').click()
        cy.wait(500)

        cy.get('[data-test="code-output"] .output-line').should('have.length', 2)
        cy.get(`[data-test="output-line-${language}"]`).should('have.length', 2)

        cy.get('[data-test="code-output"]').click()
        cy.wait(100)

        const updatedText = `Updated ${language} vow text`
        cy.get('[data-test="vow-select-active"]').eq(1).click()
        cy.get(`[data-test="vow-option-${language}"]`).click()
        cy.get('input[placeholder="Update vow text..."]').clear().type(updatedText)
        cy.contains('button', 'Update Vow').click()
        cy.wait(500)

        cy.get('[data-test="code-output"] .output-line').should('have.length', 3)
        cy.get(`[data-test="output-line-${language}"]`).should('have.length', 3)

        cy.get('[data-test="code-output"]').click()
        cy.wait(100)

        cy.get('[data-test="vow-select-active"]').first().click()
        cy.get(`[data-test="vow-option-${language}"]`).should('contain', updatedText)

        cy.get('[data-test="code-output"]').click()
        cy.wait(100)

        cy.get('[data-test="vow-select-active"]').last().click()
        cy.get(`[data-test="vow-option-${language}"]`).click()
        cy.contains('button', 'Delete Vow').click()
        cy.wait(500)

        cy.get('[data-test="code-output"] .output-line').should('have.length', 4)
        cy.get(`[data-test="output-line-${language}"]`).should('have.length', 4)
        cy.get(`[data-test="vow-option-${language}"]`).should('not.exist')

        cy.get('[data-test="vow-select-disabled"]').should('have.length', 3)
      })
    })
  })
})
