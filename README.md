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

| 01. Splash Screen | 02. Login Screen | 03. Sign Up Screen |
| :---: | :---: | :---: |
| ![Splash](https://raw.githubusercontent.com/Mdyeasinkhan4/student_task_manager_app/fea5755b84d0951cc9b04a8d192a2a119e02122a/preview_images/01.splashSC.png) | ![Login](https://raw.githubusercontent.com/Mdyeasinkhan4/student_task_manager_app/fea5755b84d0951cc9b04a8d192a2a119e02122a/preview_images/02.LoginSC.png) | ![SignUp](https://raw.githubusercontent.com/Mdyeasinkhan4/student_task_manager_app/fea5755b84d0951cc9b04a8d192a2a119e02122a/preview_images/03.SignUpSC.png) |

| 04. Tasks Dashboard | 05. Categories | 06. Calendar |
| :---: | :---: | :---: |
| ![Tasks](https://raw.githubusercontent.com/Mdyeasinkhan4/student_task_manager_app/fea5755b84d0951cc9b04a8d192a2a119e02122a/preview_images/05.TasksSC.png) | ![Categories](https://raw.githubusercontent.com/Mdyeasinkhan4/student_task_manager_app/fea5755b84d0951cc9b04a8d192a2a119e02122a/preview_images/06.CategoriesSC.png) | ![Calendar](https://raw.githubusercontent.com/Mdyeasinkhan4/student_task_manager_app/fea5755b84d0951cc9b04a8d192a2a119e02122a/preview_images/07.CalenderSC.png) |

| 07. Profile | 08. Add Task | 09. Dark Theme |
| :---: | :---: | :---: |
| ![Profile](https://raw.githubusercontent.com/Mdyeasinkhan4/student_task_manager_app/fea5755b84d0951cc9b04a8d192a2a119e02122a/preview_images/08.ProfileSC.png) | ![AddTask](https://raw.githubusercontent.com/Mdyeasinkhan4/student_task_manager_app/fea5755b84d0951cc9b04a8d192a2a119e02122a/preview_images/09.AddTaskSC.png) | ![DarkTheme](https://raw.githubusercontent.com/Mdyeasinkhan4/student_task_manager_app/fea5755b84d0951cc9b04a8d192a2a119e02122a/preview_images/10.DarkThemeSC.png) |

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
   git clone https://github.com/Mdyeasinkhan4/student_task_manager_app.git
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
