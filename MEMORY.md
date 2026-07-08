# Project Memory

## Setup & Configuration

### Supabase Setup Guide
- [SUPABASE_SETUP.md](SUPABASE_SETUP.md) - Complete guide for setting up Supabase project
- Includes: project creation, schema deployment, credentials setup, admin user creation

### Supabase Configuration
- File: `lib/config/supabase_config.dart`
- Needs credentials from Supabase dashboard
- Status: Structure ready, awaiting credentials

### Database Schema
- File: `supabase_schema.sql`
- Tables: users, tickets, comments, ticket_history, notifications
- Storage buckets: ticket_images, user_avatars
- RLS policies configured

## Admin Features Implementation

### User Management Screen
- File: `lib/screen/user_management_screen.dart`
- Features:
  - View all users
  - Change user roles (user, helpdesk, admin)
  - Activate/deactivate users
  - Role-based access control

### Admin Ticket Management Screen
- File: `lib/screen/admin_ticket_screen.dart`
- Features:
  - View all tickets with filtering
  - Filter by status (All, Menunggu, Diproses, Selesai)
  - Filter by category (All, Hardware, Software, Network, Lainnya)
  - Search by title or ticket ID
  - Assign tickets to helpdesk staff
  - Update ticket status
  - Statistics dashboard (total, waiting, in progress, completed)

### Dashboard Updates
- File: `lib/screen/dashboard_screen.dart`
- Added admin buttons:
  - "Manajemen Tiket" - Access admin ticket screen
  - "Kelola Pengguna" - Access user management (existing)

## Data Models

### User Model (`lib/models/user_model.dart`)
- Fields: id, email, name, role, studentId, className, isActive, createdAt, updatedAt
- Roles: user, helpdesk, admin
- Helper methods: isAdmin, isHelpdesk, isUser

### Ticket Model (`lib/models/ticket_model.dart`)
- Fields: id, title, description, status, category, userId, helpdeskId, imageUrl, isDeleted, createdAt, updatedAt

### Comment Model (`lib/models/comment_model.dart`)
- Fields: id, ticketId, userId, userName, content, createdAt

### History Model (`lib/models/history_model.dart`)
- Fields: id, ticketId, action, performedBy, performedByName, createdAt

### Notification Model (`lib/models/notification_model.dart`)
- Fields: id, userId, title, message, type, ticketId, isRead, createdAt

## Services & Providers

### Auth Provider (`lib/providers/auth_provider.dart`)
- Login, register, logout functionality
- Reset password
- Update profile
- Role-based access providers (isAdmin, isHelpdesk, isUser)

### Ticket Provider (`lib/providers/ticket_provider.dart`)
- Fetch tickets by role
- Create new tickets
- Update ticket status
- Assign ticket to helpdesk
- Comments and history management

### Notification Provider (`lib/providers/notification_provider.dart`)
- Fetch user notifications
- Mark as read/unread
- Unread count provider

## Dependencies
- supabase_flutter: ^2.8.2
- flutter_riverpod: ^2.6.1
- image_picker: ^1.1.2
- cached_network_image: ^3.4.1
- flutter_secure_storage: ^9.2.2
- connectivity_plus: ^6.1.0
- intl: ^0.20.1
- http: ^1.2.2

## Next Steps
1. Run SUPABASE_SETUP.md steps to configure backend
2. Update Supabase credentials in lib/config/supabase_config.dart
3. Test admin features with admin user
4. Create helpdesk users for testing
