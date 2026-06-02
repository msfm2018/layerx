# Changelog

## [1.0.0] - 2026-06-02

### 🎉 Initial Release

### ✨ Features
- Global overlay management based on `Overlay`
- Modal stack system with automatic back button handling
- Future-based API for all dialogs (await support)

### 💬 Dialogs
- `show` – simple alert dialog
- `confirm` – confirmation dialog with boolean result
- `alert` – semantic alias for alert dialog
- `input` – input dialog with text return
- `custom` – fully customizable dialog with generic result

### 📱 Sheets
- `bottomSheet` – customizable bottom sheet
- `actionSheet` – selectable action list with index result

### 🍞 Toast & Notification
- `toast` – animated toast (bottom / center)
- `toastSimple` – lightweight legacy toast
- `notification` – top notification message

### ⏳ Loading & Progress
- `loading` / `dismissLoading` – loading indicator with reference counting
- `wrapLoading` – auto loading wrapper for async tasks
- `progress` / `dismissProgress` – progress indicator

### ⚙️ Configuration
- `config` – control loading delay and minimum display duration

### 🧩 Other
- `dismiss` – close modal with result
- `dismissAll` – clear all overlay entries


