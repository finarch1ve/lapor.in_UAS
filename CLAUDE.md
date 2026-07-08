# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

E-Ticketing Helpdesk is a Flutter cross-platform application for Universitas Airlangga's IT helpdesk ticketing system. The app allows users to create, track, and manage support tickets for hardware, software, and network issues.

## Development Commands

```bash
# Install dependencies
flutter pub get

# Run the app (requires connected device or emulator)
flutter run

# Build for specific platforms
flutter build apk           # Android
flutter build ios            # iOS
flutter build windows       # Windows
flutter build web           # Web

# Run tests
flutter test

# Analyze code for issues
flutter analyze

# Format code
dart format .
```

## Architecture

### Screen Structure

All screens live under `lib/screen/`. Navigation flow:

```
SplashScreen → LoginScreen → DashboardScreen (main hub)
```

The `DashboardScreen` uses a bottom navigation bar with 4 tabs:
1. **Dashboard** (`_buildHome()`) - Shows ticket statistics and recent tickets
2. **Tiket** (`TicketListScreen`) - Lists all tickets
3. **Buat** (`CreateTicketScreen`) - Form to create new tickets
4. **Profil** (`ProfileScreen`) - User profile settings

### Theme Pattern

Theme mode (light/dark) is propagated through all screens using constructor parameters:
- Each screen receives `onToggleTheme: VoidCallback` and `themeMode: ThemeMode`
- The toggle function is defined in `main.dart`'s `_MyAppState`
- Theme toggle icon appears in app bars of `LoginScreen` and `DashboardScreen`

### Data Layer

**No backend integration currently.** All ticket data is stored in `lib/screen/ticket_data.dart` as a static `List<Map<String, dynamic>>` in the `TicketData` class. When adding backend integration:

1. Replace `TicketData.tickets` with API calls
2. Update `CreateTicketScreen._submitTicket()` to POST to backend
3. Update `TicketListScreen` to fetch from backend
4. Update `TicketDetailScreen` history display to use API responses

### Ticket Domain Model

Tickets contain:
- `id`: Auto-generated (e.g., "#001")
- `title`: Issue title
- `status`: "Menunggu" (Waiting), "Diproses" (In Progress), "Selesai" (Completed)
- `date`: Formatted as "DD MMM YYYY" with Indonesian month abbreviations
- `category`: "Hardware", "Software", "Network", "Lainnya"
- `history`: List of activity records with `action`, `time`, and `by` fields

### Language

The UI uses Indonesian language throughout. When adding new features, maintain Indonesian text for user-facing elements.
