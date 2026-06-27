# EduStay - Student Accommodation Management Platform

## Overview

**EduStay** (also referred to as **StudyHub**) is a mobile-based client-server platform that facilitates searching, booking, and managing rental accommodations for university students. The platform connects students with property owners through a centralized digital system, replacing traditional paper-based and direct-communication methods that are slow, disorganized, and inefficient.

The system was developed as a graduation project at **Palestine Technical University - Kadoorie**, Faculty of Information Technology and Artificial Intelligence, Department of Computer Science.

**Supervisor:** Dr. Shadi Abu Aysheh  
**Date:** June 15, 2026

---

## Problem Statement

Currently, many university students struggle to find suitable housing easily and quickly, while landlords face challenges in showcasing their properties and reaching tenants effectively. Key challenges include:

1. No centralized and reliable source of housing information near universities
2. Time-consuming search process relying on scattered advertisements and social media
3. Incomplete or inaccurate accommodation information
4. Unstructured communication between students and property owners
5. Difficulty matching budget, location, and facility requirements
6. Lack of a unified booking and management process

---

## Features

### For Students (Tenants)
- **User Registration & Authentication** — Secure account creation and login
- **Browse & Search Properties** — Advanced search and filtering by location, price, rooms, amenities, and availability
- **Property Details** — View images, descriptions, maps, and included services
- **Booking System** — Submit booking requests with date range and automatic price calculation
- **Payments** — Secure electronic payment (cash/card options)
- **Reviews & Ratings** — Rate properties and read reviews from other students
- **In-App Messaging** — Chat directly with property owners
- **Favorites** — Save preferred properties for quick access
- **WhatsApp Integration** — Contact owners via WhatsApp
- **Support Tickets** — Submit maintenance requests and support inquiries
- **Profile Management** — Manage personal information and settings

### For Property Owners
- **Property Management** — Add, edit, and manage property listings with images
- **Booking Management** — View and manage incoming booking requests
- **Communication** — Chat with tenants and respond to inquiries
- **Reviews** — Reply to property reviews and feedback

### For Administrators
- **User Management** — Manage all user accounts and roles
- **Listing Management** — Approve, edit, or remove property listings
- **Dashboard & Reports** — View statistics, charts, occupancy rates, and payment analytics
- **Support Management** — Track and resolve support tickets and complaints
- **System Monitoring** — Full CRUD operations and system activity oversight

---

## Tech Stack

### Backend
| Technology | Purpose |
|------------|---------|
| **Laravel 12** | PHP web framework (REST API) |
| **PHP 8.2** | Server-side language |
| **MySQL (InnoDB)** | Relational database with referential integrity |
| **Laravel Sanctum** | Bearer token authentication |
| **Composer** | PHP dependency manager |

### Mobile
| Technology | Purpose |
|------------|---------|
| **Flutter** | Cross-platform mobile framework |
| **Dart** | Programming language |
| **Provider** | State management |
| **Google Maps Flutter** | Location and mapping |
| **Cached Network Image** | Image loading and caching |
| **Image Picker** | Image selection from device |

### Tools & Methodology
- **Methodology:** Agile (iterative development with sprints)
- **Version Control:** Git & GitHub
- **Local Environment:** XAMPP (Apache + MySQL + PHP)
- **Testing:** PHPUnit (12 tests, 39 assertions)

---

## Database Schema

The database design follows the source of truth defined in `schema.sql`, consisting of **11 core tables**:

| Table | Description |
|-------|-------------|
| `users` | User accounts with role-based access (admin, owner, user) |
| `properties` | Property listings with pricing, location, amenities, and availability |
| `property_images` | Multiple images per property |
| `bookings` | Reservation records with full pricing breakdown (base price, discounts, service fees, security deposit, final total) |
| `payments` | Payment tracking (cash/card) with unique reference per booking |
| `messages` | In-app messaging between users (sent, delivered, seen states) |
| `reviews` | Property ratings and reviews with owner reply support |
| `favorites` | Saved properties per user |
| `support_messages` | Support ticket system for inquiries and complaints |
| `user_whatsapp_numbers` | Multiple WhatsApp numbers per user |
| `personal_access_tokens` | Sanctum authentication tokens |

---

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/register` | User registration |
| POST | `/api/login` | User login (returns Sanctum token) |
| GET | `/api/me` | Get authenticated user |
| PUT | `/api/update-profile` | Update user profile |
| POST | `/api/logout` | Logout (revoke token) |
| GET | `/api/properties` | List all properties |
| GET | `/api/properties/{id}` | Get property details |
| POST | `/api/properties` | Create property listing (owner) |
| POST | `/api/bookings` | Create a booking |
| GET | `/api/bookings` | Get user's bookings |
| POST | `/api/payments` | Process payment |
| GET | `/api/messages` | Get messages |
| POST | `/api/messages` | Send a message |
| GET | `/api/reviews` | Get reviews |
| POST | `/api/reviews` | Submit a review |
| POST | `/api/favorites` | Toggle favorite |
| POST | `/api/support` | Send support message |
| GET | `/api/whatsapp-numbers` | Get WhatsApp numbers |

---

## Installation

### Backend Setup

```bash
# Navigate to backend directory
cd backend

# Install PHP dependencies
composer install

# Copy environment file
cp .env.example .env

# Generate application key
php artisan key:generate

# Configure database in .env
#   DB_DATABASE=EduStay
#   DB_USERNAME=root
#   DB_PASSWORD=

# Run migrations
php artisan migrate

# Start development server
php artisan serve
```

### Mobile Setup

```bash
# Navigate to mobile directory
cd mobile

# Install Flutter dependencies
flutter pub get

# Run the app
flutter run
```

---

## Testing

All backend tests pass successfully:

```bash
cd backend && php artisan test
```

- ✅ 12 tests
- ✅ 39 assertions
- ✅ Authentication, booking overlap checking, role-based access, and payment ownership verified

---

## Team Members

| Name | University ID | Role |
|------|--------------|------|
| Anas Azzam Sous | <!-- ID --> | Team Member |
| Yaser Jehad Zabadi | <!-- ID --> | Team Member |
| Amer Saeed Kittaneh | <!-- ID --> | Team Member |
| Mohammad Mazooz Ghanem | <!-- ID --> | Team Member |

---

## Links

- **GitHub Repository:** [github.com/Amer-3w/accommodation-management-project](https://github.com/Amer-3w/accommodation-management-project)
- **Video:** <!-- Add your video link here -->

---

## License

This project was developed as a graduation project for educational purposes at Palestine Technical University - Kadoorie.