import type { Language } from '../../src/types/vow'

describe('CRUD Operations', () => {
  const languages: Language[] = ['typescript', 'go', 'python']

  beforeEach(() => {
    cy.visit('/')
    // Wait for initial load
    cy.get('[data-test="code-output"]').should('be.visible')
    // Verify all selects are disabled initially
    cy.get('[data-test="vow-select-disabled"]').should('have.length', 3)
  })

  languages.forEach((language) => {
    describe(`${language} vows`, () => {
      it(`should perform full CRUD cycle for ${language}`, () => {
        // CREATE
        cy.get(`[data-test="create-${language}-button"]`).click()
        cy.wait(500) // Wait for animation

        // Verify creation by checking output line count
        cy.get('[data-test="code-output"] .output-line').should('have.length', 1)
        cy.get(`[data-test="output-line-${language}"]`).should('have.length', 1)

        // Verify vow selects become active
        cy.get('[data-test="vow-select-active"]').should('have.length', 3)

        // READ
        cy.get('[data-test="vow-select-active"]').first().click()
        cy.get(`[data-test="vow-option-${language}"]`).click()
        cy.contains('button', 'Read Vow').click()
        cy.wait(500)

        // Verify read by checking output line count
        cy.get('[data-test="code-output"] .output-line').should('have.length', 2)
        cy.get(`[data-test="output-line-${language}"]`).should('have.length', 2)

        // UPDATE - click outside first to ensure dropdowns are closed
        cy.get('[data-test="code-output"]').click()
        cy.wait(100) // Wait for dropdown to close

        const updatedText = `Updated ${language} vow text`
        cy.get('[data-test="vow-select-active"]').eq(1).click()
        cy.get(`[data-test="vow-option-${language}"]`).click()
        cy.get('input[placeholder="Update vow text..."]').clear().type(updatedText)
        cy.contains('button', 'Update Vow').click()
        cy.wait(500)

        // Verify update
        cy.get('[data-test="code-output"] .output-line').should('have.length', 3)
        cy.get(`[data-test="output-line-${language}"]`).should('have.length', 3)

        // Click outside before checking updated text
        cy.get('[data-test="code-output"]').click()
        cy.wait(100)

        // Verify updated text in options
        cy.get('[data-test="vow-select-active"]').first().click()
        cy.get(`[data-test="vow-option-${language}"]`).should('contain', updatedText)

        // DELETE - click outside first
        cy.get('[data-test="code-output"]').click()
        cy.wait(100)

        cy.get('[data-test="vow-select-active"]').last().click()
        cy.get(`[data-test="vow-option-${language}"]`).click()
        cy.contains('button', 'Delete Vow').click()
        cy.wait(500)

        // Verify deletion
        cy.get('[data-test="code-output"] .output-line').should('have.length', 4)
        cy.get(`[data-test="output-line-${language}"]`).should('have.length', 4)
        cy.get(`[data-test="vow-option-${language}"]`).should('not.exist')

        // After DELETE, verify selects become disabled again
        cy.get('[data-test="vow-select-disabled"]').should('have.length', 3)
      })
    })
  })
})
