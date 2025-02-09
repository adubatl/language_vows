# Language Vows

_What a cool anagram of golang+vue+aws. Yes I named the project first, then built the application based on the name._

A Vue 3 + TypeScript application for managing programming language vows, with a Go backend and PostgreSQL database.

## Development Setup

### Prerequisites

- Node.js (v18+)
- Go (v1.23+)
- Docker and Docker Compose
- VSCode (or Cursor) (recommended)

### VSCode Configuration

1. Install the recommended extensions:

   - Vue.volar (Vue 3 support)
   - vitest.explorer (Unit testing)
   - dbaeumer.vscode-eslint (ESLint)
   - EditorConfig.EditorConfig (EditorConfig)
   - esbenp.prettier-vscode (Prettier)
   - skellock.just (Justfile support)

2. Add the following to your VSCode settings.json (already configured in .vscode/settings.json):
   ```json
   {
     "editor.formatOnSave": true,
     "editor.defaultFormatter": "esbenp.prettier-vscode",
     "editor.codeActionsOnSave": {
       "source.fixAll": "explicit"
     },
     "files.associations": {
       "justfile": "just"
     }
   }
   ```

### Project Setup

1. Install dependencies:

   ```sh
   npm install
   ```

2. Start the database:

   ```sh
   just db-up
   ```

3. Initialize the database:

   ```sh
   just db-init-all
   ```

4. Start the backend (database + Go server):

   ```sh
   just be
   ```

5. Start the frontend:

   ```sh
   just fe
   ```

The application should now be running at http://localhost:5173

## Available Commands

### Frontend (npm/just)

- `just fe` or `just frontend-up` - Start development server
- `npm run build` - Build for production
- `npm run test:unit` - Run unit tests
- `npm run test:e2e` - Run end-to-end tests
- `npm run lint` - Lint code
- `npm run format` - Format code with Prettier

### Backend (just)

- `just be` or `just start` - Start both database and backend
- `just db-up` - Start PostgreSQL container
- `just db-down` - Stop PostgreSQL container
- `just db-init` - Initialize database schema
- `just db-restore` - Restore from seed data
- `just go-run` - Start Go backend server
- `just db-connect` - Connect to PostgreSQL database
- `just db-tables` - Show all tables
- `just db-vows` - Show contents of vows table
- `just db-count [table]` - Count rows in a table
- `just db-clear` - Clear all vows
- `just db-backup [type]` - Backup database
- `just db-init-all` - Initialize schema and seed data

## Project Structure
