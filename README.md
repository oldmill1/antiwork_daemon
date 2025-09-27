# Antiwork Daemon

A macOS automation tool that combines computer vision with mouse control to automate web applications, currently only designed for Slack automation in mind.

## 🎯 What It Does

This app demonstrates a powerful "AI eyes + mouse" approach to automation that bypasses traditional APIs by using computer vision to "see" interface elements and control them with precise mouse movements.

## ✨ Features

### 🖱️ Mouse Control
- **Move Mouse to Top Left/Right**: Basic mouse positioning
- **Go to Home Button**: Uses Vision API to detect and click the Home button in Slack
- **Test Coordinates**: Debug tool for screen coordinate testing

### 👁️ Computer Vision (Apple Vision API)
- **Test Vision**: Toggle display of test screenshot
- **Analyze Image with Vision**: Detects text and UI elements in images
- **Smart Sidebar Detection**: Specifically finds navigation elements in the left sidebar
- **Coordinate Conversion**: Converts normalized Vision coordinates to actual screen pixels

### 🌐 Chrome & Slack Integration
- **Test Chrome Detection**: Verifies if Google Chrome is running (using NSWorkspace)
- **Open Slack Environment**: 
  - Detects if Chrome is running
  - Starts Chrome if needed
  - Opens Slack URL: `https://app.slack.com/client/T069D5CG1/C03K10RTDLL`

## 🚀 How It Works

1. **Vision Detection**: Uses Apple's Vision API to analyze screenshots and detect text elements
2. **Coordinate Mapping**: Converts Vision's normalized coordinates (0-1) to actual screen pixels
3. **Mouse Automation**: Moves cursor to precise locations using `CGWarpMouseCursorPosition`
4. **App Management**: Uses NSWorkspace to detect and launch applications

## 🎮 Demo Workflow

1. **Setup**: Click "Open Slack Environment" to launch Chrome and open Slack
2. **Vision**: Click "Test Vision" to show the screenshot, then "Analyze Image with Vision"
3. **Automation**: Click "Go To Home Button" to automatically detect and click the Home button

## 🔧 Technical Stack

- **SwiftUI**: Modern macOS app interface
- **Vision Framework**: Apple's machine learning text recognition
- **NSWorkspace**: Application management and URL opening
- **Core Graphics**: Mouse cursor control
- **AppleScript**: Chrome tab management (when needed)

## 🎯 The Vision

This is the foundation for building intelligent automation tools that can:
- **See** what users see (computer vision)
- **Understand** interface elements (text detection)
- **Act** like a human user (mouse control)
- **Bypass** API limitations and rate limits
- **Work** with any web application

## 🚀 Future Possibilities

- Auto-respond to Slack messages
- Smart channel navigation
- Automated file organization
- Status updates based on calendar
- Bulk message management
- And much more...

---

*Built with ❤️ for automating the boring parts of work*