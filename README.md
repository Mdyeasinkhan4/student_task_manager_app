# 📝 Student Task Manager App

A powerful and user-friendly Task Management application designed to help students organize their daily tasks and academic activities efficiently. Built with Flutter, this app integrates the Ostad Learning REST API and Firebase services.

---

## ✨ Key Features

- 🔐 **Multi-Authentication System:**
  - Traditional Email & Password sign-in.
  - **Firebase Google Sign-In** for seamless social login access.
- 📊 **Dynamic Task Dashboard:** Real-time task counting based on status: New, Progress, Completed, and Cancelled.
- 🚩 **Custom Priority System:**
  - Assign importance levels to tasks using **Priority Flags**.
  - Visual indicators: **High (Red)**, **Medium (Orange)**, and **Low (Green)**.
- 🖼️ **Profile Management:**
  - Update user information (Name, Mobile, Password).
  - **Profile Picture** upload support directly from the device gallery (Base64 encoded).
- 📱 **Cross-Platform Compatibility:** Optimized for Android, iOS, and Web browsers.
- 🔄 **Auto-Sync:** Seamless data synchronization via REST API and Firebase metadata.
- 🏗️ **State Management (Provider):** Centralized and reactive state management for authentication and user data, ensuring UI consistency across the app.

---

## 📸 Screenshots

*(Replace these placeholders with your project's actual screenshots)*

| Login Screen | Dashboard | Add New Task |
| :---: | :---: | :---: |
| ![Login](https://via.placeholder.com/200x400?text=Login+Screen) | ![Dashboard](https://via.placeholder.com/200x400?text=Dashboard) | ![Add Task](https://via.placeholder.com/200x400?text=Add+Task+Screen) |

| Profile Section | Task Priority | Web View |
| :---: | :---: | :---: |
| ![Profile](https://via.placeholder.com/200x400?text=Profile+Update) | ![Priority](https://via.placeholder.com/200x400?text=Priority+Flag) | ![Web View](https://via.placeholder.com/400x200?text=Responsive+Web+View) |

---

## 🛠 Tech Stack

- **Frontend:** [Flutter](https://flutter.dev/)
- **State Management:** [Provider](https://pub.dev/packages/provider)
- **Backend API:** Ostad REST API
- **Auth & Backend:** [Firebase Authentication](https://firebase.google.com/docs/auth)
- **Utilities:** [Image Picker](https://pub.dev/packages/image_picker), [Shared Preferences](https://pub.dev/packages/shared_preferences)
- **Data Format:** JSON & Base64 (for images)

---

## 🚀 Getting Started

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/student_task_manager_app.git
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase:**
   - Add your `google-services.json` (for Android) to the `android/app/` directory.
   - For Web, ensure your Firebase config is initialized in `main.dart`.

4. **Run the application:**
   ```bash
   flutter run
   ```

---

## 🤝 Contribution
Contributions are welcome! If you'd like to improve this project, feel free to fork the repository and submit a **Pull Request**.

---

### 👨‍💻 Developer
- **Md. Yeasin Khan**

---
⭐️ If you find this project helpful, please give it a star!
