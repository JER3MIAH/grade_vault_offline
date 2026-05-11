# GradeVault Offline

A free, open-source school result management application built with Flutter. Works completely offline — no internet connection, no subscriptions, no limits.

## Features

- **Student Management** — Add and manage student records across classes and terms
- **Grading System** — Fully customisable grade ranges, remarks, and colours
- **PDF Reports** — Generate professional result sheets and annual broad sheets
- **School Customisation** — Configure school name, logo, motto, address, contact details, and branches
- **Offline-First** — All data stored locally on-device using Hive (AES-256 encrypted)
- **Multi-Term Support** — Track First, Second, and Third Term results per session
- **Annual Broad Sheet** — Consolidated yearly performance view per student
- **Custom Subjects** — Extend the built-in subject list with your own subjects
- **No Limits** — Generate unlimited PDF reports, manage unlimited students and classes

## Getting Started

### Prerequisites

- Flutter SDK 3.x or later
- Dart 3.x or later

### Installation

```bash
git clone https://github.com/JER3MIAH/grade_vault_offline.git
cd grade_vault_offline
flutter pub get
flutter run
```

### First Launch

On first launch you will be prompted to enter your school details (name, motto, address, contact info). All fields except **School Name** are optional and can be updated later in **Settings → School Settings**.

## Usage

### Managing Classes
1. From the Home screen, tap **+ New Class**
2. Enter the class name, teacher name, academic session, and branch (if applicable)

### Adding Students
1. Open a class and tap **+ Add Student**
2. Enter the student's name and optional details

### Recording Grades
1. Open a student record and select a term
2. Add subjects and enter scores for each assessment component

### Generating Reports
- **Result Sheet** — Open a class → tap the generate icon → select a term
- **Broad Sheet** — Open a class → tap ⋮ → Annual Broad Sheet → Generate PDF

### School Settings
Go to **Settings → School Settings** to manage:
- School information (name, motto, address, website, established year)
- Contact details (email, phone numbers)
- Branches / campuses
- Grading system (add, edit, or delete grade ranges)
- Custom subjects
- Custom class name templates
- Display options (show/hide final position on reports)

## Project Structure

```
lib/
├── src/
│   ├── core/
│   │   ├── config/          # App configuration and defaults
│   │   ├── constants/       # Subject list, class list, term list, etc.
│   │   └── navigation/      # Route definitions and generator
│   ├── features/
│   │   ├── home/            # Classes, students, grades, PDF generation
│   │   ├── settings/        # App settings, school settings
│   │   ├── onboarding/      # First-time school setup
│   │   └── splash/          # Splash screen
│   └── shared/              # Shared widgets and utilities
```

## Tech Stack

| Library | Purpose |
|---|---|
| [Flutter](https://flutter.dev) | UI framework |
| [Riverpod](https://riverpod.dev) | State management |
| [Hive](https://docs.hivedb.dev) | Local offline storage |
| [flutter_hooks](https://pub.dev/packages/flutter_hooks) | Hook-based widget lifecycle |
| [pdf](https://pub.dev/packages/pdf) | PDF generation |

## Contributing

Contributions are welcome! Please open an issue to discuss what you'd like to change, then submit a pull request.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Commit your changes (`git commit -m 'feat: add my feature'`)
4. Push to the branch (`git push origin feature/my-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
