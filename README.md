SwiftLibgd is a Swift wrapper for libgd, providing server-side image manipulation where Core Graphics isn’t available. Built for Swift 6.2+.

It allows you to:
- Load and save PNG/JPEG images.
- Create, resize, and crop images.
-	Draw lines, shapes (ellipses, rectangles), and images.
-	Read and write individual pixels.
-	Flood fill colors.
-	Flip images horizontally or vertically.
-	Apply basic effects: pixelate, blur, colorize, desaturate.

SwiftLibgd handles GD resources automatically, freeing memory when images are destroyed.


## Installation

1. Install the GD library on your system:
-	macOS: Install Homebrew, then run:
```
brew install gd
```
- Linux: Run as root:
```
apt-get install libgd-dev
```

2.	Add SwiftLibgd to your `Package.swift`:
```
.package(url: "https://github.com/brillcp/swiftlibgd.git", from: "0.1.2")
```

3. Include SwiftLibgd in your target dependencies.
SwiftLibgd has a single Swift dependency: Cgd, which wraps the underlying GD library.
