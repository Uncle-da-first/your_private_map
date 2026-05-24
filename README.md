# 📍 MapNoLog

> A privacy layer for map apps — use any map, share nothing real.

[![License: MIT](https://img.shields.io/badge/License-MIT-teal.svg)](https://opensource.org/licenses/MIT)
![Platform: Flutter / Android](https://img.shields.io/badge/Platform-Flutter%20%2F%20Android-purple.svg)
![Privacy: High](https://img.shields.io/badge/Privacy-No%20Tracking-green.svg)

Every time you open Google Maps, Apple Maps, or any navigation app, your real GPS coordinates, device ID, and behavioral patterns are silently logged and profiled. **MapNoLog** intercepts that data before it leaves your device and substitutes it with randomized but plausible values — so you navigate normally, but the map provider learns nothing real about you.

---

## 👁️ The Problem
Map apps collect your precise location history, search queries, route patterns, and device fingerprint continuously — even when you're not actively navigating. This data is used for profiling, sold to advertisers, and retained indefinitely. Existing privacy-focused maps (OsmAnd, Organic Maps) require switching away from familiar apps and accepting lower map quality.

## 🛡️ Core Features
* **🎯 Location Fuzzing:** Your real location is shown to you accurately, but a slightly offset coordinate (±300–800m, randomized per session) is reported to the map app.
* **🔄 Identity Rotation:** Advertising IDs and session identifiers are rotated regularly, preventing long-term behavioral profiling.
* **📱 On-Device Only:** No server, no account, no data ever leaves your device through us.
* **🗺️ Works with Any Map App:** Seamlessly use Google Maps, Apple Maps, Waze, or any other navigation app.

---

## ⚡ Comparison

| Feature / App | Organic Maps / OsmAnd | MapNoLog |
| :--- | :---: | :---: |
| **Privacy Guaranteed** | ✅ | ✅ |
| **No App Switching Needed** | ❌ | ✅ |
| **High Map & Traffic Quality** | ❌ | ✅ |

---

## 🛠️ Tech Stack
* **Frontend Framework:** Flutter
* **Language:** Dart
* **Target OS:** Android (Primary), iOS (Planned)
* **Architecture:** Fully On-Device / Stateless

## 🚀 Project Status & Contribution
🛠️ **MVP is in active development.** We are building a Flutter-based Android app focusing on the core location fuzzing toggle. 

We welcome all skill levels! Check open issues on GitHub, join the discussions, or try the app and report bugs. Documentation, translations, and UI/UX design help are just as valuable as code.

---
*MIT License · No telemetry · No ads · No accounts · Built in public*