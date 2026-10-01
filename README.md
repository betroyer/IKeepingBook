# I-Keeping Books

Offline Android book inventory — Flutter, Provider, SQLite.

## Run

```bash
flutter pub get
flutter run
```

Requires an Android device or emulator (hypervisor/acceleration enabled). A debug APK is produced with:

```bash
flutter build apk --debug
```

Output: `build/app/outputs/flutter-apk/app-debug.apk`

## Features

- Dashboard vitals (titles, copies, categories, low stock)
- Books CRUD with search, sort, and category filter
- Five fixed categories from the product plan
- Low-stock signal when quantity ≤ 5
- Student borrow: multi-book checklist per checkout, due-soon alerts, optional Gmail receipts
- Local librarian accounts (sign up / log in) on SQLite
- Dark mode, clear-all with confirmation, About
- Local SQLite on device; Windows/desktop uses SQLite FFI so login works there too

## Structure

Matches the plan: `models/`, `database/`, `providers/`, `services/`, `screens/`, `widgets/`, `theme/`, `utils/`.
