# API Documentation for Wanzo Backend

This document outlines the expected API endpoints, request/response formats, and data models for the Wanzo application backend. This is based on an analysis of the frontend application's service calls and data structures.

**Base URL:** `http://localhost:3000/api` (configurable in `ApiClient`)

**Authentication:** Most endpoints require Bearer Token authentication. The token should be included in the `Authorization` header: `Authorization: Bearer <YOUR_TOKEN>`.

## General API Conventions

### Request Format
- All request bodies should be in JSON format (`Content-Type: application/json`).
- Dates are expected in ISO 8601 format (e.g., `YYYY-MM-DDTHH:mm:ss.sssZ`).

### Response Format
- Successful responses (2xx status codes) will generally return JSON.
- A common successful response structure:
  ```json
  {
    "success": true,
    "message": "Descriptive message",
    "data": { /* requested data or result of operation */ },
    "statusCode": 200 // or 201, etc.
    // "pagination": { ... } // for list endpoints
  }
  ```
- Error responses (4xx, 5xx status codes) will also return JSON:
  ```json
  {
    "success": false,
    "message": "Error description",
    "statusCode": 400 // or 401, 403, 404, 500, etc.
    // "errors": { /* field-specific validation errors */ } // Optional
  }
  ```

### CRUD Operations Overview

**1. Create (POST)**
   - **Endpoint:** `POST /api/{resource}`
   - **Request Body:** JSON object representing the new resource.
   - **Success Response:** 201 Created, with the created resource in the `data` field.

**2. Read (GET)**
   - **Get All:** `GET /api/{resource}`
     - Supports query parameters for pagination (`page`, `limit`), sorting (`sortBy`, `sortOrder`), and filtering.
     - Success Response: 200 OK, with an array of resources in `data`.
   - **Get One by ID:** `GET /api/{resource}/{id}`
     - Success Response: 200 OK, with the single resource in `data`.

**3. Update (PUT)**
   - **Endpoint:** `PUT /api/{resource}/{id}`
   - **Request Body:** JSON object with fields to be updated.
   - **Success Response:** 200 OK, with the updated resource in `data`.

**4. Delete (DELETE)**
   - **Endpoint:** `DELETE /api/{resource}/{id}`
   - **Success Response:** 200 OK (with a confirmation message) or 204 No Content.

---

## Specific API Endpoints

### A. Products
- **Base Endpoint:** `/products`
- **Service:** `ProductApiService`
- **Model:** `Product` (see `lib/features/inventory/models/product.dart`)
- **Operations:**
    - `GET /api/products`: List products.
        - Query Params: pagination, sorting, filtering.
    - `POST /api/products`: Create a new product.
    - `GET /api/products/{id}`: Get a specific product.
    - `PUT /api/products/{id}`: Update a product.
    - `DELETE /api/products/{id}`: Delete a product.
- **Product JSON Structure (Example):**
  ```json
  {
    "id": "string (UUID or ObjectId)",
    "name": "string",
    "description": "string",
    "sku": "string",
    "barcode": "string",
    "categoryId": "string",
    "unitId": "string",
    "purchasePrice": "number",
    "sellingPrice": "number",
    "quantityInStock": "number",
    "reorderLevel": "number",
    "supplierId": "string",
    "imageUrl": "string",
    "attributes": [{"name": "string", "value": "string"}],
    "createdAt": "iso8601_string_date",
    "updatedAt": "iso8601_string_date"
  }
  ```

### B. Customers
- **Base Endpoint:** `/customers`
- **Service:** `CustomerApiService` (see `lib/core/services/customer_api_service.dart`)
- **Model:** `Customer` (see `lib/features/customers/models/customer.dart`)
- **Operations:**
    - `GET /api/customers`: List customers.
    - `POST /api/customers`: Create a new customer.
    - `GET /api/customers/{id}`: Get a specific customer.
    - `PUT /api/customers/{id}`: Update a customer.
    - `DELETE /api/customers/{id}`: Delete a customer.
- **Customer JSON Structure (Example):**
  ```json
  {
    "id": "string",
    "fullName": "string",
    "phoneNumber": "string",
    "email": "string",
    "address": "string",
    "createdAt": "iso8601_string_date",
    "notes": "string",
    "totalPurchases": "number",
    "profilePicture": "string"
  }
  ```

### C. Sales
- **Base Endpoint:** `/sales`
- **Service:** `SaleApiService`
- **Models:** `Sale`, `SaleItem` (see `lib/features/sales/models/`)
- **Operations:**
    - `GET /api/sales`: List sales.
    - `POST /api/sales`: Create a new sale.
    - `GET /api/sales/{id}`: Get a specific sale.
    - `PUT /api/sales/{id}`: Update a sale.
    - `DELETE /api/sales/{id}`: Delete a sale.
- **Sale JSON Structure (Example):**
  ```json
  {
    "id": "string",
    "customerId": "string",
    "saleDate": "iso8601_string_date",
    "totalAmount": "number",
    "amountPaid": "number",
    "paymentStatus": "string",
    "paymentMethodId": "string",
    "notes": "string",
    "userId": "string",
    "items": [
      {
        "productId": "string",
        "quantity": "number",
        "unitPrice": "number",
        "totalPrice": "number"
      }
    ],
    "createdAt": "iso8601_string_date",
    "updatedAt": "iso8601_string_date"
  }
  ```

### D. Subscriptions
- **Base Endpoint:** `/subscription`
- **Repository:** `SubscriptionRepository`
- **Models:** `SubscriptionTier`, `Invoice`, `PaymentMethod` (subscription-specific)
- **Operations:**
    - `GET /api/subscription/tiers`: Get available subscription tiers.
    - `GET /api/subscription/details`: Get current user's subscription details.
    - `POST /api/subscription/change-tier`: Change subscription tier.
      - Body: `{ "newTierType": "string" }`
    - `POST /api/subscription/topup-tokens`: Add tokens.
      - Body: `{ "tokenPackageId": "string", "paymentDetails": { ... } }`
    - `POST /api/subscription/payment-proof`: Upload payment proof (multipart/form-data).
    - `GET /api/subscription/invoices`: List user's invoices.
    - `GET /api/subscription/payment-methods`: List user's payment methods.
- **SubscriptionTier JSON (Example):**
  ```json
  {
    "id": "string",
    "type": "string",
    "name": "string",
    "price": "string",
    "users": "number",
    "adhaTokens": "number",
    "features": ["string"]
  }
  ```

### E. Authentication
- **Base Endpoint:** `/auth` (Convention, actual might vary slightly based on Auth0 or custom setup)
- **Service:** `AuthRepository`, `Auth0Service`
- **Operations:**
    - `POST /api/auth/login`: User login.
      - Body: `{ "email": "string", "password": "string" }` (for credentials) or OAuth flow.
      - Response: `{ "token": "jwt_string", "user": { ... } }`
    - `POST /api/auth/register`: User registration.
    - `POST /api/auth/refresh-token`: Refresh access token.
    - `GET /api/auth/me` (or `/api/user/profile`): Get current authenticated user.

    ---
    **New Operation for Auth0 Management API Token Retrieval:**
    - **Endpoint:** `POST /api/auth/management-token`
    - **Description:** Securely obtains an Auth0 Management API token for the authenticated user. The backend handles the secure retrieval of this token from Auth0 (e.g., using Client Credentials Grant with backend-stored M2M application credentials). This token is intended for the client to update its own user metadata in Auth0.
    - **Request Body (JSON):**
        ```json
        {} // Empty body, user context derived from authentication token
        ```
    - **Response (JSON - Success 200 OK):**
        ```json
        {
          "success": true,
          "message": "Auth0 Management API token retrieved successfully.",
          "data": {
            "managementApiToken": "string" // The Auth0 Management API token
          },
          "statusCode": 200
        }
        ```
    - **Security Notes:**
        - The backend must securely store its Auth0 M2M client ID and secret.
        - The Management API token obtained by the backend should have the minimum necessary scopes (e.g., `update:users_app_metadata` for the user's own `user_metadata` and `read:users_app_metadata`, and potentially `update:users` and `read:users` if root attributes like `name` or `picture` are being modified). It's crucial to request only the permissions needed. For instance, if only `user_metadata` is updated, `update:users_app_metadata` and `read:users_app_metadata` might suffice. If standard profile attributes (like name, nickname, picture) are also updated via this token, then `update:users` and `read:users` would be required.
        - This endpoint must be protected and only accessible by authenticated users.
    ---

### F. Suppliers
- **Base Endpoint:** `/suppliers`
- **Model:** `Supplier` (see `lib/features/supplier/models/supplier.dart`)
- **Operations:** CRUD similar to Products/Customers.
- **Supplier JSON Structure (Example):**
  ```json
  {
    "id": "string",
    "name": "string",
    "contactPerson": "string",
    "email": "string",
    "phoneNumber": "string",
    "address": "string",
    "category": "string (enum: strategic, regular, newSupplier, occasional, international)",
    "totalPurchases": "number",
    "lastPurchaseDate": "iso8601_string_date",
    "createdAt": "iso8601_string_date",
    "updatedAt": "iso8601_string_date"
  }
  ```

### G. Adha (AI Chat)
- **Base Endpoint:** `/adha` or `/chat` (Backend to confirm final)
- **Repository:** `AdhaRepository` (Frontend)
- **Models:** `ChatMessage`, `Conversation` (Frontend: `lib/features/adha/models/`)

**Core Interaction Principles:**
-   **Conversational Grouping:** All messages are part of a specific conversation, identified by a `conversationId`.
-   **Isolated Context per Conversation:** Each conversation has its own distinct context, which must be carefully managed and isolated from other conversations. The context is established at the beginning of a conversation and maintained throughout.

**Context Handling for Adha:**
The context for Adha is prepared by the frontend in the background and sent with each message. It includes a base context (always present) and an optional interaction-specific context.

*   **Base Context (Always Sent by Frontend):**
    *   `operationJournalSummary`: A structured summary of recent or relevant entries from the Operation Journal. This provides Adha with ongoing awareness of general business activities. The exact structure (e.g., last N entries, entries from last X days, specific types of operations) needs to be defined.
    *   `businessProfile`: Key information about the user's business (name, sector, address, etc., as defined in the User Profile section L).

*   **Interaction-Specific Context (Determined by User Action):**
    *   `interactionType`: An enum indicating the nature of the user's current interaction focus.
        *   `generic_card_analysis`: User clicked a UI card for specific analysis (e.g., "Analyse de ventes").
        *   `direct_initiation`: User started a new conversation by typing directly, without a card trigger.
        *   `follow_up`: User is continuing an existing conversation.
    *   `interactionData`: Data specific to the `interactionType`.
        *   For `generic_card_analysis`: Contains data relevant to the selected card's topic, potentially period-tagged (e.g., sales data for Q1). `sourceIdentifier` would name the card (e.g., `'sales_analysis_q1_card'`).
        *   For `direct_initiation`: Could be empty or include keywords extracted from the user's initial query if applicable.
        *   For `follow_up`: Typically minimal or absent from the frontend, as the primary follow-up context (conversation history) is managed by the backend.

**Operations:**

1.  **Send Message / Start or Continue Conversation:**
    *   **Endpoint:** `POST /api/adha/message` (Backend to confirm final, e.g., `/api/chat/send`)
    *   **Description:** Sends a user's message to Adha. The `contextInfo` field is crucial and must be included with every message.
    *   **Request Body (JSON):**
        ```json
        {
          "userId": "string", // Authenticated user ID (derived from token by backend)
          "text": "string",   // User's message
          "conversationId": "string | null", // Null to start a new conversation, ID to continue
          "timestamp": "iso8601_string_date", // Timestamp of message creation
          "contextInfo": {
            "baseContext": {
              "operationJournalSummary": { 
                /* Example:
                "recentEntries": [
                  {"timestamp": "iso_date", "description": "Sale #123 created"},
                  {"timestamp": "iso_date", "description": "Product 'XYZ' stock updated"}
                ],
                "summaryMetrics": {"totalSalesToday": 1500, "newCustomers": 2}
                */
              },
              "businessProfile": {
                "businessName": "string",
                "businessSector": "string",
                // ... other relevant fields from User Profile (Section L)
              }
            },
            "interactionContext": {
              "interactionType": "string (enum: 'generic_card_analysis', 'direct_initiation', 'follow_up')",
              "sourceIdentifier": "string | null", // e.g., 'sales_analysis_card', 'user_direct_input'
              "interactionData": { 
                /* Optional: JSON object with data specific to the interaction.
                   - For 'generic_card_analysis': Data related to the card (sales, inventory, etc.).
                   - For 'direct_initiation': Minimal or keywords.
                   - For 'follow_up': Typically absent.
                   The exact structure of this data needs to be agreed upon with the backend.
                */
              }
            }
          }
        }
        ```
    *   **Response (JSON - Success 200 OK):**
        ```json
        {
          "success": true,
          "message": "Reply successfully generated.",
          "data": {
            "replyText": "string", // AI's response
            "conversationId": "string", // ID of the current or new conversation
            "messageId": "string", // ID of the AI's reply message
            "timestamp": "iso8601_string_date"
            // Potentially other metadata like tokens consumed, etc.
          },
          "statusCode": 200
        }
        ```

2.  **List Conversations:**
    *   **Endpoint:** `GET /api/adha/conversations`
    *   **Description:** Retrieves a list of conversations for the authenticated user.
    *   **Query Params:** `page`, `limit`, `sortBy (e.g., lastMessageTimestamp)`, `sortOrder`.
    *   **Response (JSON - Success 200 OK):**
        ```json
        {
          "success": true,
          "message": "Conversations fetched successfully.",
          "data": [
            {
              "conversationId": "string",
              "title": "string", // e.g., "Sales Analysis Chat" or first user message snippet
              "lastMessageSnippet": "string",
              "lastMessageTimestamp": "iso8601_string_date",
              "unreadMessages": "number" // Optional
            }
            // ... more conversations
          ],
          "pagination": { /* standard pagination object */ },
          "statusCode": 200
        }
        ```

3.  **Get Conversation History:**
    *   **Endpoint:** `GET /api/adha/conversations/{conversationId}/messages`
    *   **Description:** Retrieves the message history for a specific conversation.
    *   **URL Parameters:** `conversationId`
    *   **Query Params:** `page`, `limit` (for paginating messages within a long conversation).
    *   **Response (JSON - Success 200 OK):**
        ```json
        {
          "success": true,
          "message": "Conversation history fetched.",
          "data": [
            {
              "messageId": "string",
              "text": "string",
              "sender": "string (enum: 'user', 'ai')",
              "timestamp": "iso8601_string_date",
              "contextUsed": { /* Optional: summary of context active for this AI message, if available */ }
            }
            // ... more messages
          ],
          "pagination": { /* standard pagination object */ },
          "statusCode": 200
        }
        ```

### H. Expenses
- **Base Endpoint:** `/expenses`
- **Repository:** `ExpenseRepository`
- **Models:** `Expense`, `ExpenseCategory` (see `lib/features/expenses/models/`)
- **Operations:** Standard CRUD.
    - `GET /api/expenses`: List expenses.
        - Query Params: `page`, `limit`, `dateFrom`, `dateTo`, `categoryId`, `sortBy`, `sortOrder`.
    - `POST /api/expenses`: Create a new expense.
    - `GET /api/expenses/{id}`: Get a specific expense.
    - `PUT /api/expenses/{id}`: Update an expense.
    - `DELETE /api/expenses/{id}`: Delete an expense.
- **Expense JSON Structure (Example):**
  ```json
  {
    "id": "string",
    "userId": "string", // Automatically from authenticated user
    "date": "iso8601_string_date",
    "amount": "number",
    "description": "string",
    "categoryId": "string", // Reference to ExpenseCategory
    "paymentMethod": "string", // e.g., "cash", "card", "bank_transfer"
    "receiptUrl": "string", // Optional URL to an uploaded receipt image
    "createdAt": "iso8601_string_date",
    "updatedAt": "iso8601_string_date"
  }
  ```
- **ExpenseCategory Operations:**
    - `GET /api/expense-categories`: List expense categories.
    - `POST /api/expense-categories`: Create an expense category (Admin).
    - `PUT /api/expense-categories/{id}`: Update an expense category (Admin).
    - `DELETE /api/expense-categories/{id}`: Delete an expense category (Admin).
- **ExpenseCategory JSON Structure (Example):**
  ```json
  {
    "id": "string",
    "name": "string",
    "description": "string"
  }
  ```

### I. Financing
- **Base Endpoint:** `/financing`
- **Repository:** `FinancingRepository`
- **Model:** `FinancingRecord` (see `lib/features/financing/models/`)
- **Operations:** Standard CRUD.
    - `GET /api/financing/records`: List financing records.
    - `POST /api/financing/records`: Create a new financing record.
    - `GET /api/financing/records/{id}`: Get a specific record.
    - `PUT /api/financing/records/{id}`: Update a record.
    - `DELETE /api/financing/records/{id}`: Delete a record.
- **FinancingRecord JSON Structure (Example):**
  ```json
  {
    "id": "string",
    "userId": "string", // Automatically from authenticated user
    "type": "string (e.g., 'loan', 'investment', 'grant', 'equity')",
    "sourceOrPurpose": "string", // e.g., "Bank X Loan", "Seed Investment Round", "Operational Costs"
    "amount": "number",
    "date": "iso8601_string_date", // Date of transaction or record
    "terms": "string", // Description of terms, interest rate, repayment schedule, equity details
    "status": "string (e.g., 'pending', 'active', 'repaid', 'closed', 'defaulted')",
    "relatedDocuments": [ // Optional URLs to contracts, agreements
      { "name": "string", "url": "string" }
    ],
    "createdAt": "iso8601_string_date",
    "updatedAt": "iso8601_string_date"
  }
  ```

### J. Notifications
- **Base Endpoint:** `/notifications`
- **Repository:** `NotificationRepository`
- **Model:** `Notification` (see `lib/features/notifications/models/notification_model.dart`)
- **Operations:**
    - `GET /api/notifications`: Get user's notifications (paginated).
        - Query Params: `page`, `limit`, `status (e.g., 'read', 'unread')`.
    - `POST /api/notifications/{id}/mark-read`: Mark a specific notification as read.
    - `POST /api/notifications/mark-all-read`: Mark all unread notifications as read for the user.
    - `DELETE /api/notifications/{id}`: Delete a notification.
    - (Note: Sending notifications is typically a backend-initiated process, e.g., via triggers or admin actions, not a direct client API call to send to *other* users).
- **Notification JSON Structure (Example from `notification_model.dart`):**
  ```json
  {
    "id": "string",
    "userId": "string", // To whom the notification belongs
    "title": "string",
    "body": "string",
    "receivedAt": "iso8601_string_date", // When the notification was generated/sent
    "readAt": "iso8601_string_date", // Null if unread
    "type": "string (e.g., 'info', 'alert', 'reminder', 'new_sale', 'stock_alert')",
    "data": { // Optional payload for client-side routing or actions
      "entityType": "string (e.g., 'sale', 'product')",
      "entityId": "string"
    }
  }
  ```

### K. Operation Journal (Audit Log)
- **Base Endpoint:** `/operation-journal` or `/audit-logs`
- **Repository:** `OperationJournalRepository`
- **Model:** `JournalEntry` (or similar, see `lib/features/dashboard/models/operation_journal_entry.dart`)
- **Operations:**
    - `GET /api/operation-journal`: List journal entries.
        - Query Params: `page`, `limit`, `dateFrom`, `dateTo`, `userId` (for admins), `operationType`, `resourceAffected`.
    - (Note: Journal entries are typically created automatically by the backend as a side effect of other operations. Direct client creation is unlikely.)
- **JournalEntry JSON Structure (Example):**
  ```json
  {
    "id": "string",
    "timestamp": "iso8601_string_date",
    "userId": "string", // User who performed the action
    "userName": "string", // For easier display
    "operationType": "string (e.g., 'CREATE_PRODUCT', 'UPDATE_SALE', 'USER_LOGIN')",
    "resourceAffected": "string (e.g., 'Product', 'Sale', 'User')", // Optional: Main entity type
    "resourceId": "string", // Optional: ID of the affected entity
    "description": "string", // Human-readable summary of the action
    "details": { // Optional: Structured data about the change (e.g., old/new values for an update)
      "fieldName": "string",
      "oldValue": "any",
      "newValue": "any"
    },
    "ipAddress": "string", // Optional
    "userAgent": "string" // Optional
  }
  ```

### L. Settings & User Profile
- **Base Endpoint:** `/settings` and `/user/profile`
- **Repository:** `SettingsRepository`, `AuthRepository`
- **Models:** `Settings` (see `lib/features/settings/models/settings.dart`), `User` (see `lib/features/auth/models/user.dart`), `BusinessSector` (see `lib/features/auth/models/business_sector.dart`)
- **Operations for User Settings:**
    - `GET /api/settings`: Get current user's application settings.
    - `PUT /api/settings`: Update user's application settings.
- **Settings JSON Structure (Example from `settings.dart`):**
  ```json
  {
    // userId is implicit from authenticated user
    "themeMode": "string (e.g., 'light', 'dark', 'system')",
    "language": "string (e.g., 'en', 'fr')",
    "currency": "string (e.g., 'USD', 'CDF')",
    "notificationsEnabled": { // Granular notification preferences
       "appUpdates": "boolean",
       "newSales": "boolean",
       "stockAlerts": "boolean",
       "lowTokenBalance": "boolean"
    },
    "defaultInvoiceNotes": "string",
    "defaultSaleTerms": "string"
    // Other app-specific preferences
  }
  ```
- **Operations for User Profile (subset of User model, often includes business details):**
    - `GET /api/user/profile`: Get current authenticated user's profile information.
    - `PUT /api/user/profile`: Update user's profile information.
- **User Profile JSON Structure (for PUT, GET might include more like `id`, `email`):**
  ```json
  {
    "firstName": "string",
    "lastName": "string",
    "phoneNumber": "string",
    // Business-related fields
    "businessName": "string",
    "businessSectorId": "string", // From BusinessSector list
    "businessAddress": "string",
    "businessLogoUrl": "string" // URL to uploaded logo
    // "email" is usually not updatable here, or via a separate verification process
  }
  ```
- **Business Sectors (supporting endpoint):**
    - `GET /api/business-sectors`: List available business sectors for selection.
    - **BusinessSector JSON Structure:**
      ```json
      {
        "id": "string",
        "name": "string",
        "description": "string"
      }
      ```

---
### M. Company Profile
- **Base Endpoint:** `/api/company`
- **Service:** (Assumed `CompanyApiService` or similar in `lib/features/company/services/`)
- **Operations:**
    - `GET /api/company`: Retrieve the current user's company profile.
        - **Response (JSON - Success 200 OK):**
          ```json
          {
            "success": true,
            "message": "Company profile retrieved successfully.",
            "data": {
              "id": "string",
              "name": "string",
              "registrationNumber": "string",
              "taxId": "string",
              "address": "string",
              "city": "string",
              "country": "string",
              "phoneNumber": "string",
              "email": "string",
              "website": "string",
              "logoUrl": "string",
              "industry": "string",
              "createdAt": "iso8601_string_date",
              "updatedAt": "iso8601_string_date"
            },
            "statusCode": 200
          }
          ```
    - `PUT /api/company`: Update the company profile.
        - **Request Body (JSON):**
          ```json
          {
            "name": "string",
            "registrationNumber": "string",
            "taxId": "string",
            "address": "string",
            "city": "string",
            "country": "string",
            "phoneNumber": "string",
            "email": "string",
            "website": "string",
            "industry": "string"
          }
          ```
        - **Response (JSON - Success 200 OK):** (Returns the updated company profile, similar to GET response)

    - `POST /api/company/logo`: Upload or update the company logo.
        - **Request:** `multipart/form-data` with a file field (e.g., `logoFile`).
        - **Response (JSON - Success 200 OK):**
          ```json
          {
            "success": true,
            "message": "Company logo updated successfully.",
            "data": {
              "logoUrl": "string" // URL of the uploaded/updated logo
            },
            "statusCode": 200
          }
          ```

---
### N. Document Management
- **Base Endpoint:** `/api/documents`
- **Service:** (Assumed `DocumentApiService` or similar in `lib/features/documents/services/`)
- **Operations:**
    - `POST /api/documents/upload`: Upload a document.
        - **Request:** `multipart/form-data` including:
            - `file`: The document file.
            - `entityId`: \"string\" (ID of the entity this document is related to, e.g., sale ID, customer ID).
            - `entityType`: \"string\" (Type of the entity, e.g., \"sale\", \"customer\", \"expense\").
            - `documentType`: \"string\" (e.g., \"invoice\", \"receipt\", \"contract\", \"other\").
            - `description`: \"string\" (Optional description).
        - **Response (JSON - Success 201 Created):**
          ```json
          {
            "success": true,
            "message": "Document uploaded successfully.",
            "data": {
              "id": "string",
              "fileName": "string",
              "fileUrl": "string",
              "documentType": "string",
              "entityId": "string",
              "entityType": "string",
              "uploadedAt": "iso8601_string_date"
            },
            "statusCode": 201
          }
          ```
    - `GET /api/documents`: List documents, typically filtered.
        - **Query Params:** `entityId`, `entityType`, `documentType`, `page`, `limit`.
        - **Response (JSON - Success 200 OK):** (Array of document objects as in POST response, with pagination)
    - `GET /api/documents/{id}`: Get a specific document's details.
        - **Response (JSON - Success 200 OK):** (Single document object)
    - `DELETE /api/documents/{id}`: Delete a document.
        - **Response (JSON - Success 200 OK or 204 No Content):**

---
### O. Financial Transactions
- **Base Endpoint:** `/api/financial-transactions`
- **Repository:** (Assumed `TransactionRepository` in `lib/features/transactions/repositories/`)
- **Model:** (Assumed `FinancialTransaction` model)
- **Operations:**
    - `GET /api/financial-transactions`: List financial transactions.
        - **Query Params:** `page`, `limit`, `dateFrom`, `dateTo`, `type (e.g., 'payment_in', 'payment_out', 'refund')`, `status (e.g., 'pending', 'completed', 'failed')`, `paymentMethodId`.
        - **Response (JSON - Success 200 OK):** (Array of financial transaction objects, with pagination)
          ```json
          {
            "id": "string",
            "userId": "string",
            "date": "iso8601_string_date",
            "amount": "number",
            "currency": "string",
            "type": "string",
            "description": "string",
            "status": "string",
            "paymentMethodId": "string", // Optional, if applicable
            "relatedEntityId": "string", // Optional (e.g., Sale ID, Invoice ID)
            "relatedEntityType": "string", // Optional (e.g., \"sale\", \"invoice\")
            "createdAt": "iso8601_string_date",
            "updatedAt": "iso8601_string_date"
          }
          ```
    - `POST /api/financial-transactions`: Record a new financial transaction (e.g., manual entry).
        - **Request Body (JSON):** (Similar to the GET response structure, for fields that can be set by user)
        - **Response (JSON - Success 201 Created):** (The created financial transaction object)
    - `GET /api/financial-transactions/{id}`: Get a specific financial transaction.
        - **Response (JSON - Success 200 OK):** (Single financial transaction object)
    - `PUT /api/financial-transactions/{id}`: Update a financial transaction.
        - **Request Body (JSON):** (Fields to update)
        - **Response (JSON - Success 200 OK):** (The updated financial transaction object)

---
### P. Dashboard

The Dashboard feature aggregates data from various other services to provide an overview of business performance. It does not have its own dedicated API service but relies on the following services:

-   **Sales API Service**: To fetch sales data, including total sales, recent sales, and sales trends. (Refer to [Sales API](#h-sales))
-   **Customer API Service**: To fetch customer-related data, such as the number of clients served. (Refer to [Customers API](#b-customers))
-   **Financial Transactions API Service**: To fetch the count of recent transactions. (Refer to [Financial Transactions API](#o-financial-transactions))

Key Performance Indicators (KPIs) displayed on the dashboard include:
-   Sales Today
-   Clients Served Today
-   Total Receivables
-   Total Transactions Today

No specific backend endpoints are defined solely for the dashboard. It consumes data from the endpoints defined in the respective sections mentioned above.

---
This documentation should be expanded by the backend team, specifying exact request/response schemas, validation rules, and any other specific behaviors for each endpoint.
