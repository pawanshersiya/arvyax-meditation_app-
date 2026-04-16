# 🧘 ArvyaX

A calm, minimal Flutter application designed to deliver an immersive ambience-based meditation experience. ArvyaX allows users to explore curated sessions, engage in focused listening, and reflect through journaling.

---

## ✨ Features

### 🌿 Ambience Library

* Displays a curated list of ambience sessions loaded from local JSON
* Search functionality for quick discovery
* Tag-based filtering (Focus, Calm, Sleep, Reset)
* Clean and minimal UI with empty state handling

### 🎧 Session Player

* Smooth audio playback using local assets
* Looping ambience audio
* Timer-based session control (independent of audio length)
* Play/Pause controls with seek functionality
* Real-time progress tracking

### 📱 Mini Player

* Persistent bottom mini-player during active sessions
* Quick access to play/pause and session progress
* Seamless navigation back to full player

### ✍️ Reflection System

* Post-session journaling experience
* Mood selection:

    * Calm
    * Grounded
    * Energized
    * Sleepy
* Encourages mindful reflection

### 📜 Journal History

* Stores and displays past reflections
* Shows date, mood, and preview text
* Detailed view for each entry
* Handles empty state gracefully

---

## 🛠 Tech Stack

* **Flutter** – UI framework
* **Provider** – State management
* **Hive** – Lightweight local database
* **just_audio** – Audio playback

---

## 📂 Folder Structure

```
lib/
 ├── data/
 │    ├── models/        # Data models (Ambience, Journal)
 │    ├── repositories/  # Data handling logic
 │
 ├── features/
 │    ├── ambience/      # Home & Details screens
 │    ├── player/        # Session player & mini player
 │    ├── journal/       # Reflection & history
 │
 ├── shared/
 │    ├── widgets/       # Reusable UI components
 │    ├── theme/         # App theme & styling
```

---

## 🧠 Architecture

The app follows a **feature-based clean architecture** with clear separation of concerns:

* **Data Layer**
  Handles models and repositories (JSON loading, Hive storage)

* **State Layer (Provider)**
  Manages application state such as:

    * Active session
    * Audio playback
    * Journal entries

* **UI Layer**
  Contains screens and reusable widgets

This structure ensures scalability, readability, and maintainability.

---

## 🔄 Data Flow

```
Repository → Provider → UI
```

1. Data is fetched from local JSON or Hive via repositories
2. Providers manage and expose state
3. UI listens to Provider and updates reactively

---

## 📦 Packages Used

* **provider**
  For simple and efficient state management

* **hive & hive_flutter**
  For fast, lightweight local data persistence

* **just_audio**
  For reliable and flexible audio playback

* **path_provider**
  To access local storage directories

---

## ▶️ How to Run

1. Clone the repository:

   ```bash
   git clone <your-repo-link>
   cd arvyax
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Run the app:

   ```bash
   flutter run
   ```

---

## 📦 APK

> *(https://drive.google.com/file/d/1Yao4gbBof8AfLXJKcLqdk3u-pCyGs9P7/view?usp=drive_link)*

---

## 🎥 Screen Recording

> *(https://drive.google.com/file/d/1OvuhNB7-37pCJ8mWad75FWW6VnB9i4H3/view?usp=drive_link)*

---

## ⚖️ Tradeoffs

### Simplifications

* Used local JSON instead of remote API
* Basic UI animations to keep focus on functionality
* Minimal design system to meet time constraints

### Improvements (With More Time)

* Advanced animations (breathing gradients, visual effects)
* Background audio handling and lifecycle management
* Dark mode support with theme switching
* Enhanced accessibility support
* Cloud sync for journal entries

---

## 🚀 Bonus Features

* Persistent mini-player across screens
* Session state handling for seamless user experience

---

## 🧠 Final Note

ArvyaX prioritizes **clean architecture, predictable state management, and a calm user experience** over feature complexity.

---
