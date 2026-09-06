# ASL Tutor App 🤟

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-blue.svg?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green.svg)

ASL Tutor is a professional-grade, cross-platform mobile application designed to help users learn American Sign Language (ASL) through real-time, on-device AI hand tracking and interactive, gamified feedback.

---

## ✨ Features Matrix

| Feature | Description | Status |
| :--- | :--- | :---: |
| **Real-Time Tracking** | Low-latency inference locked at 60 FPS via background Isolates. | ✅ |
| **Gesture Recognition** | Maps joint coordinates to predefined ASL dictionary endpoints. | ✅ |
| **Interactive Curriculum** | Structured learning paths (Alphabet, Vowels, Core Phrases). | ✅ |
| **Gamification Engine** | Combo streaks, edge-glowing overlays, and mastery animations. | ✅ |
| **Modern UI/UX** | Immersive design with smooth micro-animations and Dark Mode. | ✅ |

---

## 🛠 Tech Stack

*   **Framework:** [Flutter](https://flutter.dev/) (Dart)
*   **State Management:** [Riverpod](https://riverpod.dev/) (Predictable, scalable, compile-safe state)
*   **Computer Vision:** `camera` + Isolate Processing (Designed for seamless ML Kit / TFLite integration)

---

## 🚀 Getting Started

### Prerequisites
*   Flutter SDK (3.x+)
*   Dart SDK
*   A physical device (Camera features do not work optimally on simulators)

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-username/asl-tutor.git
    cd asl-tutor
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Generate Riverpod code:**
    ```bash
    dart run build_runner build -d
    ```

4.  **Run the application:**
    ```bash
    flutter run
    ```

---

## 🧠 Architecture Overview

To ensure the UI remains strictly at 60 FPS, all heavy computer vision processing is offloaded to a background isolate:

1.  **`CameraService`**: Captures raw YUV/BGRA image frames from the device camera.
2.  **`IsolateProcessor`**: Spawns a background thread that receives frames via a `SendPort`, extracts skeletal landmarks (mocked in this prototype), and returns normalized `HandLandmark` coordinates.
3.  **`GestureRecognizer`**: Computes the Euclidean distance/similarity between the live coordinates and the expected constraints defined in `AslDictionary`.
4.  **Riverpod**: Subscribes to the processed state to drive the UI (e.g., updating the streak counter or toggling the green/red edge glow).

---

## 🤝 Contributing
Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## 📄 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
