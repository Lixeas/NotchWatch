import AppKit

// Standalone build-time script (run via `swift Scripts/generate-icon.swift <source.svg> <output.iconset>`
// on the macOS release runner) -- not part of the app target, iconutil needs a populated
// .iconset directory of PNGs at each required size, generated here from the vector SVG source.

let arguments = CommandLine.arguments
guard arguments.count == 3 else {
    FileHandle.standardError.write(Data("Usage: generate-icon.swift <source.svg> <output.iconset>\n".utf8))
    exit(1)
}
let sourcePath = arguments[1]
let outputDir = arguments[2]

guard let source = NSImage(contentsOfFile: sourcePath) else {
    FileHandle.standardError.write(Data("Failed to load \(sourcePath)\n".utf8))
    exit(1)
}

let sizes: [(name: String, pixels: CGFloat)] = [
    ("icon_16x16", 16), ("icon_16x16@2x", 32),
    ("icon_32x32", 32), ("icon_32x32@2x", 64),
    ("icon_128x128", 128), ("icon_128x128@2x", 256),
    ("icon_256x256", 256), ("icon_256x256@2x", 512),
    ("icon_512x512", 512), ("icon_512x512@2x", 1024)
]

try FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: true)

for (name, pixels) in sizes {
    let size = NSSize(width: pixels, height: pixels)
    let rendered = NSImage(size: size)
    rendered.lockFocus()
    NSGraphicsContext.current?.imageInterpolation = .high
    source.draw(in: NSRect(origin: .zero, size: size), from: .zero, operation: .sourceOver, fraction: 1.0)
    rendered.unlockFocus()

    guard let tiff = rendered.tiffRepresentation,
          let rep = NSBitmapImageRep(data: tiff),
          let png = rep.representation(using: .png, properties: [:]) else {
        FileHandle.standardError.write(Data("Failed to rasterize \(name)\n".utf8))
        exit(1)
    }
    let url = URL(fileURLWithPath: outputDir).appendingPathComponent("\(name).png")
    try png.write(to: url)
}

print("Wrote \(sizes.count) icon sizes to \(outputDir)")
