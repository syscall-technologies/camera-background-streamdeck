// Renders the plugin's key icons from SF Symbols. Run: swift tools/make-icons.swift
import AppKit

func render(_ symbol: String, _ color: NSColor, _ bg: NSColor, _ px: Int, _ out: String) {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: px, pixelsHigh: px, bitsPerSample: 8,
                               samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB,
                               bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    bg.setFill(); NSRect(x: 0, y: 0, width: px, height: px).fill()
    let cfg = NSImage.SymbolConfiguration(pointSize: CGFloat(px) * 0.5, weight: .regular)
        .applying(.init(paletteColors: [color]))
    let img = NSImage(systemSymbolName: symbol, accessibilityDescription: nil)!.withSymbolConfiguration(cfg)!
    let s = img.size
    img.draw(in: NSRect(x: (CGFloat(px) - s.width) / 2, y: (CGFloat(px) - s.height) / 2, width: s.width, height: s.height))
    NSGraphicsContext.current = nil
    try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: out))
}

let dir = "com.seb.camerabg.sdPlugin/imgs/"
let dark = NSColor(white: 0.1, alpha: 1)
for (name, px) in [("", 72), ("@2x", 144)] {
    render("person.and.background.dotted", .systemGreen, dark, px, dir + "on\(name).png")
    render("person.crop.rectangle", .systemGray, dark, px, dir + "off\(name).png")
    render("person.and.background.dotted", .white, dark, px, dir + "plugin\(name).png")
}
