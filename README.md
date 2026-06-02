# 🚀 LayerX

> A powerful, lightweight, and flexible **Flutter overlay & dialog management system**

<p align="center">
    <img src="https://github.com/msfm2018/layerx/blob/1.0.0/index.png?raw=true" width="300">
</p>

## ✨ Features

* 🔥 **Global overlay control** (no BuildContext required)
* 🧠 **Modal stack management** (auto back button handling)
* ⚡ **Future-based API** (await everything)
* 🧩 **Fully customizable dialogs**
* 📦 Built-in:

  * Dialog / Confirm / Alert
  * Input dialog
  * BottomSheet / ActionSheet
  * Toast / Notification
  * Loading / Progress
* 🎯 Smooth animations & minimal boilerplate

---

## 📦 Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  layerx: ^1.0.0
```

---

## ⚡ Quick Start

### 1️⃣ Initialize

```dart
MaterialApp(
  builder: LayerX.init(),
)
```

---

### 2️⃣ Use anywhere (NO context!)

```dart
LayerX.toast("Hello World");

await LayerX.show("Done");

final ok = await LayerX.confirm("Are you sure?");
```

---

## 🧩 Examples

---

### ✅ Dialog

```dart
await LayerX.show("Operation completed");
```

---

### ❓ Confirm

```dart
final result = await LayerX.confirm("Delete this item?");
```

---

### ✏️ Input

```dart
final text = await LayerX.input(
  title: "Input",
  hint: "Enter something",
);
```

---

### 🧱 Custom Dialog

```dart
final result = await LayerX.custom<String>(
  Builder(
    builder: (context) {
      return Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Custom Dialog"),
            ElevatedButton(
              onPressed: () => LayerX.dismiss(context, "OK"),
              child: const Text("Close"),
            ),
          ],
        ),
      );
    },
  ),
);
```

---

### 🍞 Toast

```dart
LayerX.toast("Hello");

LayerX.toast(
  "From center",
  fromBottom: false,
);
```

---

### 🍞 Simple Toast (legacy)

```dart
LayerX.toastSimple("Simple message");
```

---

### 🔔 Notification

```dart
LayerX.notification(
  title: "Success",
  message: "Saved successfully",
);
```

---

### 📥 Bottom Sheet

```dart
await LayerX.bottomSheet(
  Container(height: 200, child: Center(child: Text("Sheet"))),
);
```

---

### 📋 Action Sheet

```dart
final index = await LayerX.actionSheet(
  options: ["A", "B", "C"],
);
```

---

### ⏳ Loading

```dart
LayerX.loading();

// do something...

LayerX.dismissLoading();
```

---

### 🔄 Wrap with Loading

```dart
await LayerX.wrapLoading(() async {
  await Future.delayed(Duration(seconds: 2));
});
```

---

### 📊 Progress

```dart
LayerX.progress(0.6);
LayerX.dismissProgress();
```

---

## ⚙️ Configuration

```dart
LayerX.config(
  delay: Duration(milliseconds: 200),
  minShow: Duration(milliseconds: 400),
);
```

---

## 🧠 Why LayerX?

Most dialog solutions in Flutter:

* ❌ Require `BuildContext`
* ❌ Hard to manage multiple overlays
* ❌ No unified API

**LayerX solves all of them:**

* ✅ Global control
* ✅ Stack-based modal system
* ✅ Clean & consistent API
* ✅ Works anywhere

---

## 🏗 Architecture

LayerX is built on top of:

* `Overlay`
* Global modal stack
* Animation wrappers

This enables:

* Precise control
* Better UX
* Cleaner code

---

## 📱 Example App

See `/example` folder for full demo.

---

## 🤝 Contributing

PRs are welcome!
If you find a bug or have suggestions, feel free to open an issue.

---

## 📄 License

MIT License


