# Freelance Marketplace API Documentation

## Base URL
```
http://localhost:8000
```

## Authentication
All protected endpoints require a Bearer token in the Authorization header:
```
Authorization: Bearer <jwt_token>
```

## Response Format
All endpoints return responses in the following format:
```json
{
  "success": boolean,
  "data": object | array | null,
  "error": string | null
}
```

---

## Authentication Endpoints

### POST /auth/request-otp
**Purpose**: Request OTP for phone number verification
**Required auth**: None
**Required role**: None

**Request body**:
```json
{
  "phone_number": "+1234567890"
}
```

**Response body**:
```json
{
  "success": true,
  "data": {
    "message": "OTP sent successfully"
  },
  "error": null
}
```

**Example request**:
```bash
curl -X POST "http://localhost:8000/auth/request-otp" \
  -H "Content-Type: application/json" \
  -d '{"phone_number": "+1234567890"}'
```

**Example response**:
```json
{
  "success": true,
  "data": {
    "message": "OTP sent successfully"
  },
  "error": null
}
```

---

### POST /auth/verify-otp
**Purpose**: Verify OTP code and obtain JWT token
**Required auth**: None
**Required role**: None

**Request body**:
```json
{
  "phone_number": "+1234567890",
  "code": "1234",
  "firebase_token": "optional_firebase_token"
}
```

**Response body**:
```json
{
  "success": true,
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "token_type": "bearer",
    "expires_in": 86400
  },
  "error": null
}
```

**Example request**:
```bash
curl -X POST "http://localhost:8000/auth/verify-otp" \
  -H "Content-Type: application/json" \
  -d '{"phone_number": "+1234567890", "code": "1234"}'
```

**Example response**:
```json
{
  "success": true,
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3OC05YWJjLWRlZi0xMjM0LTU2Nzg5YWJjZGVmMCIsImV4cCI6MTcwMzE3NzYwMH0.abc123",
    "token_type": "bearer",
    "expires_in": 86400
  },
  "error": null
}
```

---

### POST /auth/select-role
**Purpose**: Add a role (client/freelancer) to authenticated user
**Required auth**: Bearer token
**Required role**: Any authenticated user

**Request headers**:
```
Authorization: Bearer <jwt_token>
```

**Request body**:
```json
{
  "role": "freelancer"
}
```

**Response body**:
```json
{
  "success": true,
  "data": {
    "message": "Role freelancer added successfully"
  },
  "error": null
}
```

**Example request**:
```bash
curl -X POST "http://localhost:8000/auth/select-role" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <jwt_token>" \
  -d '{"role": "freelancer"}'
```

---

## User Endpoints

### GET /users/me
**Purpose**: Get current user information
**Required auth**: Bearer token
**Required role**: Any authenticated user

**Request headers**:
```
Authorization: Bearer <jwt_token>
```

**Response body**:
```json
{
  "success": true,
  "data": {
    "user_id": "12345678-9abc-def1-2345-6789abcdef12",
    "name": "John",
    "surname": "Doe",
    "phone_number": "+1234567890",
    "roles": ["freelancer"],
    "created_at": "2023-12-01T10:00:00Z",
    "updated_at": "2023-12-01T10:00:00Z"
  },
  "error": null
}
```

**Example request**:
```bash
curl -X GET "http://localhost:8000/users/me" \
  -H "Authorization: Bearer <jwt_token>"
```

---

### PUT /users/me
**Purpose**: Update current user information
**Required auth**: Bearer token
**Required role**: Any authenticated user

**Request headers**:
```
Authorization: Bearer <jwt_token>
```

**Request body**:
```json
{
  "name": "John",
  "surname": "Smith",
  "phone_number": "+1234567891"
}
```

**Response body**:
```json
{
  "success": true,
  "data": {
    "user_id": "12345678-9abc-def1-2345-6789abcdef12",
    "name": "John",
    "surname": "Smith",
    "phone_number": "+1234567891",
    "roles": ["freelancer"],
    "created_at": "2023-12-01T10:00:00Z",
    "updated_at": "2023-12-01T10:30:00Z"
  },
  "error": null
}
```

---

## Freelancer Endpoints

### POST /freelancers/profile
**Purpose**: Create freelancer profile
**Required auth**: Bearer token
**Required role**: Any authenticated user

**Request headers**:
```
Authorization: Bearer <jwt_token>
```

**Request body**:
```json
{
  "iin": "123456789012",
  "city": "Almaty",
  "email": "john@example.com",
  "specializations_with_levels": [
    {
      "specialization": "Python Development",
      "skill_level": "senior"
    },
    {
      "specialization": "React Development",
      "skill_level": "middle"
    }
  ],
  "experience_description": "5 years of experience in full-stack development",
  "phone_number": "+1234567890",
  "bio": "Experienced developer passionate about clean code",
  "payment_info": {
    "bank_account": "KZ123456789012345678",
    "payment_methods": ["bank_transfer", "kaspi"]
  },
  "social_links": {
    "linkedin": "https://linkedin.com/in/johndoe",
    "github": "https://github.com/johndoe"
  },
  "portfolio_links": {
    "website": "https://johndoe.dev",
    "behance": "https://behance.net/johndoe"
  },
  "avatar_url": "https://example.com/avatar.jpg"
}
```

**Response body**:
```json
{
  "success": true,
  "data": {
    "freelancer_id": "87654321-9abc-def1-2345-6789abcdef12",
    "user_id": "12345678-9abc-def1-2345-6789abcdef12",
    "iin": "123456789012",
    "city": "Almaty",
    "email": "john@example.com",
    "specializations_with_levels": [
      {
        "specialization": "Python Development",
        "skill_level": "senior"
      }
    ],
    "experience_description": "5 years of experience in full-stack development",
    "phone_number": "+1234567890",
    "status": "pending",
    "bio": "Experienced developer passionate about clean code",
    "payment_info": {
      "bank_account": "KZ123456789012345678"
    },
    "social_links": {
      "linkedin": "https://linkedin.com/in/johndoe"
    },
    "portfolio_links": {
      "website": "https://johndoe.dev"
    },
    "avatar_url": "https://example.com/avatar.jpg",
    "created_at": "2023-12-01T10:00:00Z",
    "updated_at": "2023-12-01T10:00:00Z"
  },
  "error": null
}
```

---

### GET /freelancers/profile
**Purpose**: Get current user's freelancer profile
**Required auth**: Bearer token
**Required role**: freelancer

**Request headers**:
```
Authorization: Bearer <jwt_token>
```

**Response body**:
```json
{
  "success": true,
  "data": {
    "freelancer_id": "87654321-9abc-def1-2345-6789abcdef12",
    "user_id": "12345678-9abc-def1-2345-6789abcdef12",
    "iin": "123456789012",
    "city": "Almaty",
    "email": "john@example.com",
    "specializations_with_levels": [
      {
        "specialization": "Python Development",
        "skill_level": "senior"
      }
    ],
    "experience_description": "5 years of experience in full-stack development",
    "phone_number": "+1234567890",
    "status": "approved",
    "created_at": "2023-12-01T10:00:00Z",
    "updated_at": "2023-12-01T10:00:00Z"
  },
  "error": null
}
```

---

### PUT /freelancers/profile
**Purpose**: Update freelancer profile
**Required auth**: Bearer token
**Required role**: freelancer

**Request headers**:
```
Authorization: Bearer <jwt_token>
```

**Request body**:
```json
{
  "city": "Nur-Sultan",
  "experience_description": "6 years of experience in full-stack development",
  "bio": "Updated bio"
}
```

**Response body**:
```json
{
  "success": true,
  "data": {
    "freelancer_id": "87654321-9abc-def1-2345-6789abcdef12",
    "city": "Nur-Sultan",
    "experience_description": "6 years of experience in full-stack development",
    "bio": "Updated bio",
    "updated_at": "2023-12-01T11:00:00Z"
  },
  "error": null
}
```

---

### GET /freelancers/
**Purpose**: Get list of approved freelancers (public)
**Required auth**: None
**Required role**: None

**Query Parameters**:
- `page`: Page number (default: 1)
- `size`: Items per page (default: 20, max: 100)

**Response body**:
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "freelancer_id": "87654321-9abc-def1-2345-6789abcdef12",
        "user_id": "12345678-9abc-def1-2345-6789abcdef12",
        "city": "Almaty",
        "email": "john@example.com",
        "specializations_with_levels": [
          {
            "specialization": "Python Development",
            "skill_level": "senior"
          }
        ],
        "status": "approved"
      }
    ],
    "total": 1,
    "page": 1,
    "size": 20,
    "pages": 1
  },
  "error": null
}
```

---

## Client Endpoints

### POST /clients/profile
**Purpose**: Create client profile
**Required auth**: Bearer token
**Required role**: Any authenticated user

**Request headers**:
```
Authorization: Bearer <jwt_token>
```

**Request body**:
```json
{
}
```

**Response body**:
```json
{
  "success": true,
  "data": {
    "client_id": "11111111-9abc-def1-2345-6789abcdef12",
    "user_id": "12345678-9abc-def1-2345-6789abcdef12",
    "company_ids": [],
    "created_at": "2023-12-01T10:00:00Z",
    "updated_at": "2023-12-01T10:00:00Z"
  },
  "error": null
}
```

---

### GET /clients/profile
**Purpose**: Get current user's client profile
**Required auth**: Bearer token
**Required role**: client

**Request headers**:
```
Authorization: Bearer <jwt_token>
```

**Response body**:
```json
{
  "success": true,
  "data": {
    "client_id": "11111111-9abc-def1-2345-6789abcdef12",
    "user_id": "12345678-9abc-def1-2345-6789abcdef12",
    "company_ids": ["22222222-9abc-def1-2345-6789abcdef12"],
    "created_at": "2023-12-01T10:00:00Z",
    "updated_at": "2023-12-01T10:00:00Z"
  },
  "error": null
}
```

---

## Company Endpoints

### POST /companies/
**Purpose**: Create a new company
**Required auth**: Bearer token
**Required role**: client

**Request headers**:
```
Authorization: Bearer <jwt_token>
```

**Request body**:
```json
{
  "company_name": "Tech Innovations Ltd",
  "company_industry": "Technology",
  "client_position": "CEO",
  "company_size": 50,
  "company_logo": "https://example.com/logo.png",
  "company_description": "A leading technology company focused on innovation"
}
```

**Response body**:
```json
{
  "success": true,
  "data": {
    "company_id": "22222222-9abc-def1-2345-6789abcdef12",
    "client_id": "11111111-9abc-def1-2345-6789abcdef12",
    "company_name": "Tech Innovations Ltd",
    "company_industry": "Technology",
    "client_position": "CEO",
    "company_size": 50,
    "company_logo": "https://example.com/logo.png",
    "company_description": "A leading technology company focused on innovation",
    "created_at": "2023-12-01T10:00:00Z",
    "updated_at": "2023-12-01T10:00:00Z"
  },
  "error": null
}
```

---

### GET /companies/my
**Purpose**: Get current client's companies with all linked orders
**Required auth**: Bearer token
**Required role**: client

**Request headers**:
```
Authorization: Bearer <jwt_token>
```

**Response body**:
```json
{
  "success": true,
  "data": [
    {
      "company_id": "22222222-9abc-def1-2345-6789abcdef12",
      "client_id": "11111111-9abc-def1-2345-6789abcdef12",
      "company_name": "Tech Innovations Ltd",
      "company_industry": "Technology",
      "client_position": "CEO",
      "company_size": 50,
      "company_orders": ["33333333-9abc-def1-2345-6789abcdef12"],
      "orders": [
        {
          "order_id": "33333333-9abc-def1-2345-6789abcdef12",
          "order_description": "Need a senior Python developer",
          "order_status": "approved",
          "order_complete_status": "pending",
          "created_at": "2023-12-01T10:00:00Z"
        }
      ],
      "created_at": "2023-12-01T10:00:00Z"
    }
  ],
  "error": null
}
```

---

### GET /companies/{company_id}
**Purpose**: Get company details
**Required auth**: Bearer token
**Required role**: Any authenticated user

**Request headers**:
```
Authorization: Bearer <jwt_token>
```

**Response body**:
```json
{
  "success": true,
  "data": {
    "company_id": "22222222-9abc-def1-2345-6789abcdef12",
    "client_id": "11111111-9abc-def1-2345-6789abcdef12",
    "company_name": "Tech Innovations Ltd",
    "company_industry": "Technology",
    "client_position": "CEO",
    "company_size": 50,
    "company_logo": "https://example.com/logo.png",
    "company_description": "A leading technology company",
    "created_at": "2023-12-01T10:00:00Z",
    "updated_at": "2023-12-01T10:00:00Z"
  },
  "error": null
}
```

---

## Order Endpoints

### POST /orders/create
**Purpose**: Create a new order with full details
**Required auth**: Bearer token
**Required role**: Any authenticated user

**Request headers**:
```
Authorization: Bearer <jwt_token>
```

**Request body**:
```json
{
  "name": "John",
  "surname": "Doe",
  "company_name": "Tech Corp",
  "company_position": "CTO",
  "order_description": "We need a senior Python developer for a 6-month project",
  "order_title": "Senior Python Developer",
  "order_specializations": [
    {
      "specialization": "Python Development",
      "skill_level": "senior",
      "conditions": {
        "salary": 3000,
        "pay_per": "month",
        "required_experience": 5,
        "schedule_type": "full-time",
        "format_type": "remote"
      },
      "requirements": "5+ years Python experience, FastAPI knowledge required"
    },
    {
      "specialization": "PostgreSQL",
      "skill_level": "middle",
      "conditions": {
        "required_experience": 3
      },
      "requirements": "Experience with complex queries and optimization"
    }
  ],
  "chat_link": "https://t.me/techcorp_hiring"
}
```

**Response body**:
```json
{
  "success": true,
  "data": {
    "order_id": "33333333-9abc-def1-2345-6789abcdef12",
    "company_id": "22222222-9abc-def1-2345-6789abcdef12",
    "order_description": "We need a senior Python developer for a 6-month project",
    "order_status": "pending",
    "order_complete_status": "pending",
    "order_title": "Senior Python Developer",
    "order_specializations": [
      {
        "specialization": "Python Development",
        "skill_level": "senior",
        "conditions": {
          "salary": 3000,
          "pay_per": "month",
          "required_experience": 5,
          "schedule_type": "full-time",
          "format_type": "remote"
        },
        "requirements": "5+ years Python experience, FastAPI knowledge required"
      }
    ],
    "chat_link": "https://t.me/techcorp_hiring",
    "order_colleagues": null,
    "contracts": null,
    "created_at": "2023-12-01T10:00:00Z",
    "updated_at": "2023-12-01T10:00:00Z"
  },
  "error": null
}
```

---

### POST /orders/request-help
**Purpose**: Request admin help to create order
**Required auth**: Bearer token
**Required role**: Any authenticated user

**Request headers**:
```
Authorization: Bearer <jwt_token>
```

**Request body**:
```json
{
}
```

**Response body**:
```json
{
  "success": true,
  "data": {
    "order_id": "44444444-9abc-def1-2345-6789abcdef12",
    "company_id": "55555555-9abc-def1-2345-6789abcdef12",
    "order_description": "Need help creating a development team",
    "order_status": "pending",
    "order_complete_status": "pending",
    "created_at": "2023-12-01T10:00:00Z",
    "updated_at": "2023-12-01T10:00:00Z"
  },
  "error": null
}
```

---

### GET /orders/
**Purpose**: Get list of approved orders (for freelancers)
**Required auth**: Bearer token
**Required role**: freelancer

**Request headers**:
```
Authorization: Bearer <jwt_token>
```

**Query Parameters**:
- `page`: Page number (default: 1)
- `size`: Items per page (default: 20, max: 100)

**Response body**:
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "order_id": "33333333-9abc-def1-2345-6789abcdef12",
        "company_id": "22222222-9abc-def1-2345-6789abcdef12",
        "order_description": "We need a senior Python developer",
        "order_status": "approved",
        "order_complete_status": "pending",
        "order_title": "Senior Python Developer",
        "order_specializations": ["Python Development", "FastAPI"],
        "created_at": "2023-12-01T10:00:00Z"
      }
    ],
    "total": 1,
    "page": 1,
    "size": 20,
    "pages": 1
  },
  "error": null
}
```

---

### GET /orders/my
**Purpose**: Get all orders created by the current client
**Required auth**: Bearer token
**Required role**: client

**Request headers**:
```
Authorization: Bearer <jwt_token>
```

**Response body**:
```json
{
  "success": true,
  "data": [
    {
      "order_id": "33333333-9abc-def1-2345-6789abcdef12",
      "company_id": "22222222-9abc-def1-2345-6789abcdef12",
      "order_description": "We need a senior Python developer for a 6-month project",
      "order_status": "pending",
      "order_complete_status": "pending",
      "order_title": "Senior Python Developer",
      "order_specializations": [
        {
          "specialization": "Python Development",
          "skill_level": "senior",
          "conditions": {
            "salary": 3000,
            "pay_per": "month",
            "required_experience": 5,
            "schedule_type": "full-time",
            "format_type": "remote"
          },
          "requirements": "5+ years Python experience, FastAPI knowledge required"
        }
      ],
      "chat_link": "https://t.me/techcorp_hiring",
      "created_at": "2023-12-01T10:00:00Z",
      "updated_at": "2023-12-01T10:00:00Z"
    }
  ],
  "error": null
}
```

---

### GET /orders/{order_id}
**Purpose**: Get order details
**Required auth**: Bearer token
**Required role**: Any authenticated user

**Request headers**:
```
Authorization: Bearer <jwt_token>
```

**Response body**:
```json
{
  "success": true,
  "data": {
    "order_id": "33333333-9abc-def1-2345-6789abcdef12",
    "company_id": "22222222-9abc-def1-2345-6789abcdef12",
    "client_id": "11111111-9abc-def1-2345-6789abcdef12",
    "order_description": "We need a senior Python developer for a 6-month project",
    "order_status": "approved",
    "order_complete_status": "pending",
    "order_title": "Senior Python Developer",
    "order_specializations": [
      {
        "specialization": "Python Development",
        "skill_level": "senior",
        "conditions": {
          "salary": 3000,
          "pay_per": "month",
          "required_experience": 5,
          "schedule_type": "full-time",
          "format_type": "remote"
        },
        "requirements": "5+ years Python experience, FastAPI knowledge required"
      }
    ],
    "chat_link": "https://t.me/techcorp_hiring",
    "created_at": "2023-12-01T10:00:00Z",
    "updated_at": "2023-12-01T10:00:00Z"
  },
  "error": null
}
```

---

## Order Application Endpoints

### POST /applications/
**Purpose**: Apply to an order as a freelancer
**Required auth**: Bearer token
**Required role**: freelancer

**Request headers**:
```
Authorization: Bearer <jwt_token>
```

**Request body**:
```json
{
  "order_id": "33333333-9abc-def1-2345-6789abcdef12",
  "freelancer_id": "87654321-9abc-def1-2345-6789abcdef12"
}
```

**Response body**:
```json
{
  "success": true,
  "data": {
    "id": "66666666-9abc-def1-2345-6789abcdef12",
    "order_id": "33333333-9abc-def1-2345-6789abcdef12",
    "freelancer_id": "87654321-9abc-def1-2345-6789abcdef12",
    "company_id": "22222222-9abc-def1-2345-6789abcdef12",
    "status": "pending",
    "created_at": "2023-12-01T10:00:00Z",
    "updated_at": "2023-12-01T10:00:00Z"
  },
  "error": null
}
```

---

### GET /applications/my
**Purpose**: Get freelancer's applications
**Required auth**: Bearer token
**Required role**: freelancer

**Request headers**:
```
Authorization: Bearer <jwt_token>
```

**Response body**:
```json
{
  "success": true,
  "data": [
    {
      "id": "66666666-9abc-def1-2345-6789abcdef12",
      "order_id": "33333333-9abc-def1-2345-6789abcdef12",
      "freelancer_id": "87654321-9abc-def1-2345-6789abcdef12",
      "company_id": "22222222-9abc-def1-2345-6789abcdef12",
      "status": "pending",
      "created_at": "2023-12-01T10:00:00Z",
      "updated_at": "2023-12-01T10:00:00Z"
    }
  ],
  "error": null
}
```

---

### GET /applications/order/{order_id}
**Purpose**: Get applications for an order (for clients)
**Required auth**: Bearer token
**Required role**: client

**Request headers**:
```
Authorization: Bearer <jwt_token>
```

**Response body**:
```json
{
  "success": true,
  "data": [
    {
      "id": "66666666-9abc-def1-2345-6789abcdef12",
      "order_id": "33333333-9abc-def1-2345-6789abcdef12",
      "freelancer_id": "87654321-9abc-def1-2345-6789abcdef12",
      "company_id": "22222222-9abc-def1-2345-6789abcdef12",
      "status": "pending",
      "created_at": "2023-12-01T10:00:00Z",
      "updated_at": "2023-12-01T10:00:00Z"
    }
  ],
  "error": null
}
```

---

### PUT /applications/{application_id}
**Purpose**: Update application status (accept/reject)
**Required auth**: Bearer token
**Required role**: client

**Request headers**:
```
Authorization: Bearer <jwt_token>
```

**Request body**:
```json
{
  "status": "accepted"
}
```

**Response body**:
```json
{
  "success": true,
  "data": {
    "id": "66666666-9abc-def1-2345-6789abcdef12",
    "order_id": "33333333-9abc-def1-2345-6789abcdef12",
    "freelancer_id": "87654321-9abc-def1-2345-6789abcdef12",
    "company_id": "22222222-9abc-def1-2345-6789abcdef12",
    "status": "accepted",
    "created_at": "2023-12-01T10:00:00Z",
    "updated_at": "2023-12-01T11:00:00Z"
  },
  "error": null
}
```

---

## Admin Endpoints

### GET /admin/notifications
**Purpose**: Get admin notifications summary
**Required auth**: Bearer token
**Required role**: admin

**Request headers**:
```
Authorization: Bearer <jwt_token>
```

**Response body**:
```json
{
  "success": true,
  "data": {
    "pending_freelancers": 3,
    "pending_orders": 2,
    "recent_freelancers": [
      {
        "freelancer_id": "87654321-9abc-def1-2345-6789abcdef12",
        "email": "john@example.com",
        "status": "pending",
        "created_at": "2023-12-01T10:00:00Z"
      }
    ],
    "recent_orders": [
      {
        "order_id": "33333333-9abc-def1-2345-6789abcdef12",
        "order_title": "Senior Python Developer",
        "order_status": "pending",
        "created_at": "2023-12-01T10:00:00Z"
      }
    ]
  },
  "error": null
}
```

---

### GET /admin/freelancers/pending
**Purpose**: Get pending freelancer profiles
**Required auth**: Bearer token
**Required role**: admin

**Request headers**:
```
Authorization: Bearer <jwt_token>
```

**Query Parameters**:
- `page`: Page number (default: 1)
- `size`: Items per page (default: 20, max: 100)

**Response body**:
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "freelancer_id": "87654321-9abc-def1-2345-6789abcdef12",
        "user_id": "12345678-9abc-def1-2345-6789abcdef12",
        "email": "john@example.com",
        "city": "Almaty",
        "specializations_with_levels": [
          {
            "specialization": "Python Development",
            "skill_level": "senior"
          }
        ],
        "status": "pending",
        "created_at": "2023-12-01T10:00:00Z"
      }
    ],
    "total": 1,
    "page": 1,
    "size": 20,
    "pages": 1
  },
  "error": null
}
```

---

### PUT /admin/freelancers/{freelancer_id}/approve
**Purpose**: Approve or reject freelancer profile
**Required auth**: Bearer token
**Required role**: admin

**Request headers**:
```
Authorization: Bearer <jwt_token>
```

**Request body**:
```json
{
  "status": "approved"
}
```

**Response body**:
```json
{
  "success": true,
  "data": {
    "freelancer_id": "87654321-9abc-def1-2345-6789abcdef12",
    "user_id": "12345678-9abc-def1-2345-6789abcdef12",
    "email": "john@example.com",
    "status": "approved",
    "updated_at": "2023-12-01T11:00:00Z"
  },
  "error": null
}
```

---

### GET /admin/orders/pending
**Purpose**: Get pending orders
**Required auth**: Bearer token
**Required role**: admin

**Request headers**:
```
Authorization: Bearer <jwt_token>
```

**Query Parameters**:
- `page`: Page number (default: 1)
- `size`: Items per page (default: 20, max: 100)

**Response body**:
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "order_id": "33333333-9abc-def1-2345-6789abcdef12",
        "company_id": "22222222-9abc-def1-2345-6789abcdef12",
        "order_description": "We need a senior Python developer",
        "order_status": "pending",
        "order_title": "Senior Python Developer",
        "created_at": "2023-12-01T10:00:00Z"
      }
    ],
    "total": 1,
    "page": 1,
    "size": 20,
    "pages": 1
  },
  "error": null
}
```

---

### POST /admin/orders/{order_id}/complete
**Purpose**: Complete and approve order
**Required auth**: Bearer token
**Required role**: admin

**Request headers**:
```
Authorization: Bearer <jwt_token>
```

**Request body**:
```json
{
  "order_description": "Updated description with complete requirements",
  "order_title": "Senior Python Developer - Updated",
  "order_specializations": [
    {
      "specialization": "Python Development",
      "skill_level": "senior",
      "conditions": {
        "salary": 3500,
        "pay_per": "month",
        "required_experience": 5,
        "schedule_type": "full-time",
        "format_type": "remote"
      },
      "requirements": "Complete requirements and qualifications"
    },
    {
      "specialization": "PostgreSQL",
      "skill_level": "middle",
      "conditions": {
        "required_experience": 3
      },
      "requirements": "Database optimization experience required"
    }
  ]
}
```

**Response body**:
```json
{
  "success": true,
  "data": {
    "order_id": "33333333-9abc-def1-2345-6789abcdef12",
    "company_id": "22222222-9abc-def1-2345-6789abcdef12",
    "client_id": "11111111-9abc-def1-2345-6789abcdef12",
    "order_description": "Updated description with complete requirements",
    "order_status": "approved",
    "order_complete_status": "pending",
    "order_title": "Senior Python Developer - Updated",
    "order_specializations": [
      {
        "specialization": "Python Development",
        "skill_level": "senior",
        "conditions": {
          "salary": 3500,
          "pay_per": "month",
          "required_experience": 5,
          "schedule_type": "full-time",
          "format_type": "remote"
        },
        "requirements": "Complete requirements and qualifications"
      }
    ],
    "updated_at": "2023-12-01T11:00:00Z"
  },
  "error": null
}
```

---

### PUT /admin/orders/{order_id}/status
**Purpose**: Update order status
**Required auth**: Bearer token
**Required role**: admin

**Request headers**:
```
Authorization: Bearer <jwt_token>
```

**Request body**:
```json
{
  "order_status": "approved",
  "order_complete_status": "completed"
}
```

**Response body**:
```json
{
  "success": true,
  "data": {
    "order_id": "33333333-9abc-def1-2345-6789abcdef12",
    "order_status": "approved",
    "order_complete_status": "completed",
    "updated_at": "2023-12-01T11:00:00Z"
  },
  "error": null
}
```

---

## Health and Monitoring Endpoints

### GET /health
**Purpose**: Health check endpoint
**Required auth**: None
**Required role**: None

**Response body**:
```json
{
  "success": true,
  "data": {
    "status": "healthy"
  },
  "error": null
}
```

---

### GET /metrics
**Purpose**: Prometheus metrics endpoint
**Required auth**: None
**Required role**: None

**Response**: Prometheus metrics in text format

---

## Error Responses

All endpoints may return error responses in the following format:

### 400 Bad Request
```json
{
  "success": false,
  "data": null,
  "error": "Invalid request data"
}
```

### 401 Unauthorized
```json
{
  "success": false,
  "data": null,
  "error": "Unauthorized"
}
```

### 403 Forbidden
```json
{
  "success": false,
  "data": null,
  "error": "Forbidden"
}
```

### 404 Not Found
```json
{
  "success": false,
  "data": null,
  "error": "Resource not found"
}
```

### 422 Validation Error
```json
{
  "success": false,
  "data": [
    {
      "loc": ["body", "email"],
      "msg": "field required",
      "type": "value_error.missing"
    }
  ],
  "error": "Validation error"
}
```

### 500 Internal Server Error
```json
{
  "success": false,
  "data": null,
  "error": "Internal server error"
}
```

---

## Rate Limiting and Security

- All endpoints implement standard security headers
- CORS is configured for cross-origin requests
- Request/response logging with correlation IDs
- Input validation with Pydantic schemas
- SQL injection prevention with parameterized queries
- JWT token expiration handling

## Pagination

List endpoints support pagination with the following query parameters:
- `page`: Page number (starts from 1)
- `size`: Items per page (max 100)

Paginated responses include:
- `items`: Array of items for current page
- `total`: Total number of items
- `page`: Current page number
- `size`: Items per page
- `pages`: Total number of pages

---

## Search Endpoints

### GET /users/{user_id}
**Purpose**: Get user by ID
**Required auth**: Bearer token
**Required role**: Any authenticated user

**Request headers**:
```
Authorization: Bearer <jwt_token>
```

**Response body**:
```json
{
  "success": true,
  "data": {
    "user_id": "12345678-9abc-def1-2345-6789abcdef12",
    "name": "John",
    "surname": "Doe",
    "phone_number": "+1234567890",
    "roles": ["freelancer", "client"],
    "created_at": "2023-12-01T10:00:00Z",
    "updated_at": "2023-12-01T10:00:00Z"
  },
  "error": null
}
```

---

### GET /clients/{client_id}
**Purpose**: Get client profile by ID
**Required auth**: Bearer token
**Required role**: Any authenticated user

**Request headers**:
```
Authorization: Bearer <jwt_token>
```

**Response body**:
```json
{
  "success": true,
  "data": {
    "client_id": "11111111-9abc-def1-2345-6789abcdef12",
    "user_id": "12345678-9abc-def1-2345-6789abcdef12",
    "name": "John",
    "surname": "Doe",
    "phone_number": "+1234567890",
    "company_ids": ["22222222-9abc-def1-2345-6789abcdef12"],
    "created_at": "2023-12-01T10:00:00Z",
    "updated_at": "2023-12-01T10:00:00Z"
  },
  "error": null
}
```

---

### GET /freelancers/{freelancer_id}
**Purpose**: Get freelancer profile by ID
**Required auth**: Bearer token
**Required role**: Any authenticated user

**Request headers**:
```
Authorization: Bearer <jwt_token>
```

**Response body**:
```json
{
  "success": true,
  "data": {
    "freelancer_id": "87654321-9abc-def1-2345-6789abcdef12",
    "user_id": "12345678-9abc-def1-2345-6789abcdef12",
    "iin": "123456789012",
    "city": "Almaty",
    "email": "john@example.com",
    "specializations_with_levels": [
      {
        "specialization": "Python Development",
        "skill_level": "senior"
      }
    ],
    "experience_description": "5 years of experience in full-stack development",
    "phone_number": "+1234567890",
    "status": "approved",
    "bio": "Experienced developer passionate about clean code",
    "payment_info": {
      "bank_account": "KZ123456789012345678"
    },
    "social_links": {
      "linkedin": "https://linkedin.com/in/johndoe"
    },
    "portfolio_links": {
      "website": "https://johndoe.dev"
    },
    "avatar_url": "https://example.com/avatar.jpg",
    "created_at": "2023-12-01T10:00:00Z",
    "updated_at": "2023-12-01T10:00:00Z"
  },
  "error": null
}
```

---

## Universal Help Request

### POST /request-help
**Purpose**: Universal endpoint for requesting admin help
**Required auth**: Bearer token
**Required role**: Any authenticated user

**Request headers**:
```
Authorization: Bearer <jwt_token>
```

**Request body**:
```json
{
  "user_id": "12345678-9abc-def1-2345-6789abcdef12",
  "client_id": "11111111-9abc-def1-2345-6789abcdef12",
  "freelancer_id": "87654321-9abc-def1-2345-6789abcdef12",
  "order_id": "33333333-9abc-def1-2345-6789abcdef12",
  "company_id": "22222222-9abc-def1-2345-6789abcdef12"
}
```

**Response body**:
```json
{
  "success": true,
  "data": {
    "message": "Admin help request created successfully",
    "request_id": "44444444-9abc-def1-2345-6789abcdef12",
    "user_id": "12345678-9abc-def1-2345-6789abcdef12",
    "details": {
      "client_id": "11111111-9abc-def1-2345-6789abcdef12",
      "freelancer_id": "87654321-9abc-def1-2345-6789abcdef12",
      "order_id": "33333333-9abc-def1-2345-6789abcdef12",
      "company_id": "22222222-9abc-def1-2345-6789abcdef12"
    }
  },
  "error": null
}
```
