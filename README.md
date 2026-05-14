# 📝 Flutter To-Do App (Microsoft To Do Clone)

A highly responsive, feature-rich task management application built with **Flutter**, closely inspired by the UI/UX and functionality of **Microsoft To Do**.

This project demonstrates the implementation of **Clean Architecture**, robust state management using **Cubit (Bloc)**, and advanced local data handling, making it highly scalable and maintainable.

---

## ✨ Key Features

* **📱 Fully Responsive UI:** Adapts seamlessly across Mobile and Tablet screens (featuring a split-screen 40/60 layout for tablets).
* **☀️ My Day:** Smart daily task list that automatically resets at midnight, keeping you focused on today's goals.
* **🔁 Advanced Custom Repeat:** Highly accurate repeating tasks logic (Daily, Weekdays, Weekly, Monthly, Yearly, and Custom combinations like "Every 2 weeks on Sunday & Tuesday").
* **📋 Custom Lists:** Create and manage custom lists to categorize tasks efficiently.
* **👆 Interactive Swipe Actions:** 
  * Swipe Right: Postpone to tomorrow (or add to My Day).
  * Swipe Left: Remove from My Day or permanently delete.
* **↕️ Drag & Drop:** Reorder active tasks effortlessly using `ReorderableListView`.
* **📊 Productivity Analytics:** Real-time mini-dashboard calculating today's completion rate and consistency tracking for recurring tasks.
* **⭐ Smart Filters:** Built-in views for *Important*, *Planned*, *Completed*, and *All Tasks*.

---

## 🛠 Tech Stack & Architecture

This application strictly follows **Clean Architecture** principles to separate concerns and ensure testability.

* **Framework:** [Flutter](https://flutter.dev/)
* **State Management:** [flutter_bloc](https://pub.dev/packages/flutter_bloc) (Cubit)
* **Dependency Injection:** [get_it](https://pub.dev/packages/get_it)
* **Local Storage:** `SharedPreferences` (via a custom `CacheHelper`) with JSON encoding/decoding.
* **Responsive Design:** Custom extensions (`.w`, `.h`, `.sp`) using `LayoutBuilder` and `MediaQuery`.

### 📂 Architecture Layers
1. **Domain:** Entities and Abstract Repositories (Completely independent of any external packages).
2. **Data:** Models, Data Sources (Local/Cache), and Repository Implementations.
3. **Presentation:** Cubits (State Management), Screens, and reusable Custom Widgets.

---


## 🚀 Getting Started

### Prerequisites
* Flutter SDK (>=3.0.0)
* Dart SDK
* Android Studio / VS Code

