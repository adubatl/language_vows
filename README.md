# Language Vows

_What a cool anagram of golang+vue+aws. Yes I named the project first, then built the application based on the name._

A Vue 3 + TypeScript application for managing programming language vows, with a Go backend and PostgreSQL database.

## Development Setup

Quick n easy
brew install just && npm i && just be && just db-init-all && just fe
Disclaimer: _it worked on my machine <3_

### Prerequisites

- Node.js (v18+)
- Go (v1.23+)
- Docker and Docker Compose
- AWS CLI configured
- VSCode (or Cursor) (recommended)

### Initial Configuration

1. Set up environment files:

   ```sh
   # Create local environment file from template
   cp .env.aws.template .env.aws

   # Edit .env.aws with your AWS configuration
   # DO NOT commit this file - it contains sensitive information
   ```

2. Install dependencies:
   ```sh
   npm install
   ```

### Local Development

1. Start the database:

   ```sh
   just db-up
   ```

2. Initialize the database:

   ```sh
   just db-init-all
   ```

3. Start the backend (database + Go server):

   ```sh
   just be
   ```

4. Start the frontend:
   ```sh
   just fe
   ```

The application should now be running at http://localhost:5173

### AWS Deployment Setup

1. Configure AWS credentials:

   ```sh
   aws configure
   ```

2. Generate AWS resources:

   ```sh
   # Generate task definitions from templates
   just aws-generate-tasks

   # Set up all AWS resources
   just aws-setup-all
   ```

3. Verify setup:
   ```sh
   just aws-status-all
   ```

## Available Commands

### AWS Commands

- `just aws-generate-tasks` - Generate task definitions from templates
- `just aws-setup-all` - Full AWS infrastructure setup
- `just aws-status` - Check AWS resource status
- `just aws-status-all` - Detailed status of all AWS resources
- `just aws-cleanup` - Clean up AWS resources
- `just aws-teardown` - Full AWS cleanup including VPC and RDS

### Frontend Commands

- `just fe` or `just frontend-up` - Start development server
- `npm run build` - Build for production
- `npm run test:unit` - Run unit tests
- `npm run test:e2e` - Run end-to-end tests
- `npm run lint` - Lint code
- `npm run format` - Format code with Prettier

### Backend Commands

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

## Security Notes

- Never commit `.env.aws` or `.env.aws.generated` files
- Use `.env.aws.template` as a reference for required environment variables
- AWS credentials should be managed through AWS CLI or environment variables
- Task definitions are generated from templates to avoid committing sensitive data
- Database passwords are managed through AWS Secrets Manager
