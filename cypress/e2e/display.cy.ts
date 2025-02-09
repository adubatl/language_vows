import { Position } from '../../src/constants/missy'

describe('Display Section', () => {
  beforeEach(() => {
    cy.visit('/')
  })

  it('should cycle through Missy movements when clicking button 10 times', () => {
    const expectedStates = [
      { text: 'Flip it', position: Position.LEFT },
      { text: 'Reverse it', position: Position.LEFT },
      { text: 'Throw it back', position: Position.LEFT },
      { text: 'Flip it', position: Position.RIGHT },
      { text: 'Reverse it', position: Position.RIGHT },
      { text: 'Throw it back', position: Position.RIGHT },
      { text: 'Flip it', position: Position.LEFT },
      { text: 'Reverse it', position: Position.LEFT },
      { text: 'Throw it back', position: Position.LEFT },
      { text: 'Flip it', position: Position.RIGHT },
    ]

    expectedStates.forEach((state, index) => {
      cy.get('[data-test="display-action-button"]').click()
      cy.wait(500)

      cy.get('[data-test="display-action-button"]').should('have.text', state.text)

      cy.get('[data-test="missy-image"]').should(($img) => {
        const transform = $img[0].style.transform
        if (state.position === Position.LEFT) {
          expect(transform).to.include('translateX(-100%)')
        } else if (state.position === Position.RIGHT) {
          expect(transform).to.include('translateX(100%)')
        }
      })

      cy.log(`Verified state ${index + 1}/10`)
    })
  })
})
