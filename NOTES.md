# Go Backend Architecture Notes

## File Structure Overview

### 1. Entry Point

**`cmd/main.go`**

- Main entry point for the server
- Initializes and starts the application

### 2. API Layer

**`internal/api/router.go`**

- Initializes a Chi router (think Express.js for Go)
- Sets up middleware:
  - Logger for request logging
  - Recoverer for panic recovery
  - CORS rules for frontend communication
- Creates base route `/api` and mounts resources

**`internal/api/vows.go`**

- Contains all vows resource endpoints and logic
- Implements RESTful routes:
  - GET `/api/vows`
  - POST `/api/vows`
  - GET `/api/vows/{vowID}`
  - PUT `/api/vows/{vowID}`
  - DELETE `/api/vows/{vowID}`
- Uses those funky Go function signatures like `func (vr vowsResource) List(w http.ResponseWriter, r *http.Request)`
  > Note to self: Embrace the funk, don't fear it. (Or rewrite everything in Flask... but let's not go there)

### 3. Database Layer

**`internal/db/db.go`**

- Handles database connection setup
- Builds connection string from environment variables
- Establishes and verifies PostgreSQL connection
  > A refreshingly simple approach compared to the Django ORM.
  > (I'm slightly concerned the AI knew about my Django background without me mentioning it. Am I that predictable?)

**`internal/db/schema.sql`**

- Database schema definition
- Creates the vows table with columns:
  - id
  - text
  - language
    > Yes, I know this is obvious. I wrote it down anyway.

### 4. Models

**`internal/models/vow.go`**

- Defines the Vow struct/model
- Uses Go's backtick tags for metadata:
  ```go
  type Vow struct {
      ID       string `json:"id" db:"id"`
      Text     string `json:"text" db:"text"`
      Language string `json:"language" db:"language"`
  }
  ```
- Tags control JSON marshalling/unmarshalling
  > Fun fact: "marshalling" is just a fancy word for encoding/decoding that makes developers feel cool. There's probably some interesting history there.

### 5. Project Configuration

**`go.mod`**

- Package/dependency management file
- Like package.json for Node.js

**`go.sum`**

- Dependency lock file
- Ensures consistent builds

---

> Thanks to Claude, I am now officially the world's greatest Go developer. So great I wrote these notes by hand.
>
> (Results may vary. Professional driver on closed course. Do not attempt.)
