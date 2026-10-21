# Changelog
## [1.0.2] - 2026-10-21
### Fixed 
## [1.0.1] - 2026-06-05

### Fixed & Improved

- Added support for chaining existing `builder` in `MaterialApp` / `MaterialApp.router`.
- Provided two initialization methods for maximum compatibility:
  - `LayerX.init()` – for projects that already use a `builder` (MediaQuery, ScreenUtil, etc.).
  - `LayerX.wrapper()` – cleaner approach when you prefer not to modify `MaterialApp.builder`.

**Example Usage:**

```dart
// Method 1: Using init() with builder chaining (when you have other builders)
builder: LayerX.init(
  builder: (context, child) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: MediaQuery.of(context).textScaler.clamp(
          minScaleFactor: 0.8,
          maxScaleFactor: 1.6,
        ),
      ),
      child: child!,
    );
  },
),

// Method 2: Using wrapper() - Recommended for cleaner code
home: LayerX.wrapper(
  child: const HomePage(),
),
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


