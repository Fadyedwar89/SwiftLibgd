SwiftLibgd is a Swift wrapper for libgd, providing server-side image manipulation where Core Graphics isn’t available. It allows you to:
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

## Classes

SwiftLibgd provides five classes for basic image operations:
- Image – responsible for loading, saving, and manipulating image data
- Point – stores x and y coordinates as integers
- Size – stores width and height as integers
- Rectangle – combines Point and Size into one value
- Color – provides red, green, blue, and alpha components as Doubles from 0 to 1, and includes some built-in colors to get you started

These are implemented as classes rather than structs because only classes have deinitializers, which are required to release GD’s memory when an image is destroyed.
