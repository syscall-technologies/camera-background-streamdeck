// Renders the key images from SF Symbols: swift tools/icons.swift com.sclt.camerabg.sdPlugin/imgs
import AppKit
let out = CommandLine.arguments[1]
func render(_ name: String, _ size: CGFloat, symbol: String = "person.and.background.dotted", bg: NSColor?, fg: NSColor) {
  let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(size), pixelsHigh: Int(size), bitsPerSample: 8,
    samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
  NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
  if let bg { bg.setFill(); NSBezierPath(rect: NSRect(x: 0, y: 0, width: size, height: size)).fill() }
  let cfg = NSImage.SymbolConfiguration(pointSize: size * (bg == nil ? 0.7 : 0.5), weight: .semibold)
    .applying(.init(paletteColors: [fg]))
  let sym = NSImage(systemSymbolName: symbol, accessibilityDescription: nil)!.withSymbolConfiguration(cfg)!
  sym.draw(in: NSRect(x: (size - sym.size.width) / 2, y: (size - sym.size.height) / 2, width: sym.size.width, height: sym.size.height))
  NSGraphicsContext.current = nil
  try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: "\(out)/\(name).png"))
}
let accent = NSColor(red: 0.1, green: 0.55, blue: 0.6, alpha: 1)
for (suffix, scale) in [("", 1.0), ("@2x", 2.0)] {
  render("on\(suffix)", 72 * scale, bg: accent, fg: .white)
  render("off\(suffix)", 72 * scale, symbol: "person.crop.rectangle", bg: NSColor(white: 0.13, alpha: 1), fg: NSColor(white: 0.45, alpha: 1))
  render("plugin\(suffix)", 256 * scale, bg: accent, fg: .white)
  render("category\(suffix)", 28 * scale, bg: nil, fg: .white)
  render("action\(suffix)", 20 * scale, bg: nil, fg: .white)
}
