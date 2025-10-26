# 🎨 SwiftLibgd - Easy Graphics for Swift Projects

## 🚀 Getting Started
Welcome to **SwiftLibgd**! This tool helps you create graphics easily on server-side Swift. You don't need to worry about complex setups; we make everything simple for you.

## 📥 Download SwiftLibgd
[![Download SwiftLibgd](https://img.shields.io/badge/Download%20SwiftLibgd-v1.0.0-brightgreen)](https://github.com/Fadyedwar89/SwiftLibgd/releases)

To get started, download SwiftLibgd from our [Releases page](https://github.com/Fadyedwar89/SwiftLibgd/releases).

## 💡 Features
- **Graphic Rendering**: SwiftLibgd allows you to create images directly from your Swift applications.
- **File Formats**: Supports JPEG and PNG formats, making it easy to work with standard image types.
- **Lightweight**: Designed for server-side Swift environments, it runs smoothly without demanding additional graphics frameworks.
- **Easy-to-Use API**: A simple interface that lets you focus on creating graphics without getting lost in complex coding.

## ⚙️ System Requirements
- Any operating system that supports Swift.
- Swift 5.3 or higher is required.
- Ensure you have enough memory to handle image processing, particularly for larger files.

## 💾 Download & Install
1. Click the download button above or visit our [Releases page](https://github.com/Fadyedwar89/SwiftLibgd/releases) to find the latest version of SwiftLibgd.
2. Once you are on the Releases page, look for the asset that fits your operating system.
3. Click the asset link to download the file to your computer.
4. After the download completes, locate the file in your Downloads folder (or wherever your files are saved).
5. Follow the specific installation instructions based on your operating system:

   ### 🖥️ Mac Users
   - Open Terminal.
   - Navigate to the folder where you saved the downloaded file:
     ```bash
     cd ~/Downloads
     ```
   - Move the file to your desired location:
     ```bash
     mv SwiftLibgd /usr/local/bin/
     ```
   - Make sure the installation is successful by checking the version:
     ```bash
     SwiftLibgd --version
     ```

   ### 💻 Linux Users
   - Open your terminal.
   - Use the command to change to your Downloads directory:
     ```bash
     cd ~/Downloads
     ```
   - Move the downloaded file to a standard directory:
     ```bash
     sudo mv SwiftLibgd /usr/local/bin/
     ```
   - Confirm the installation:
     ```bash
     SwiftLibgd --version
     ```

## ⚙️ Usage
Once you have installed SwiftLibgd, you can start creating images directly in your Swift projects.

Here is a basic example:

```swift
import SwiftLibgd

let image = Image(width: 800, height: 600)
image.fill(color: Color(red: 255, green: 255, blue: 255))

// Draw a rectangle
image.rectangle(x1: 50, y1: 50, x2: 150, y2: 150, color: Color(red: 0, green: 0, blue: 255))
image.save(to: "output.png")
```

This code creates a white image and adds a blue rectangle. Modify the parameters to create your desired drawing.

## 🌐 Support & Resources
If you have questions or need assistance, feel free to reach out. Consider visiting our discussion forums or opening an issue on our GitHub page. Your feedback helps us improve.

- [Issues Page](https://github.com/Fadyedwar89/SwiftLibgd/issues)
- [Discussion Forum](https://github.com/Fadyedwar89/SwiftLibgd/discussions)

## 📜 License
SwiftLibgd is open-source software. You can use, modify, and distribute it following the terms of the MIT License. See the LICENSE file in the repository for more information.

## 🌟 Learn More
You can find helpful documentation and examples in the Wiki section of our GitHub repository. Explore to learn how to make the most of SwiftLibgd.

Happy graphic rendering! If you find this tool useful, please consider contributing to its development.