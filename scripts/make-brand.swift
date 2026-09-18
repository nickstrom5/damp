// Generates the app icon and social images from code, so the brand is reproducible.
// Run: swift scripts/make-brand.swift   (from the repo root; needs macOS, no dependencies)
import AppKit
import CoreGraphics

let navy = CGColor(red: 0.06, green: 0.07, blue: 0.10, alpha: 1)
let surface = CGColor(red: 0.11, green: 0.13, blue: 0.17, alpha: 1)
let mint = CGColor(red: 0.49, green: 0.91, blue: 0.72, alpha: 1)
let mintDeep = CGColor(red: 0.30, green: 0.75, blue: 0.58, alpha: 1)
let white = CGColor(red: 1, green: 1, blue: 1, alpha: 1)

func context(_ w: Int, _ h: Int) -> CGContext {
    let ctx = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: 0,
                        space: CGColorSpace(name: CGColorSpace.sRGB)!,
                        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    ctx.setAllowsAntialiasing(true)
    ctx.setShouldAntialias(true)
    return ctx
}

func save(_ ctx: CGContext, _ path: String) {
    let image = ctx.makeImage()!
    let rep = NSBitmapImageRep(cgImage: image)
    let data = rep.representation(using: .png, properties: [:])!
    try! data.write(to: URL(fileURLWithPath: path))
    print("wrote \(path)")
}

/// A drop: circle bottom, pointed top, with a "half full" waterline. Half full is the brand:
/// damp, not dry, not drowning.
func drawDrop(_ ctx: CGContext, center: CGPoint, height: CGFloat, fill: CGColor, waterline: Bool) {
    let r = height * 0.32
    let tip = CGPoint(x: center.x, y: center.y + height / 2)
    let c = CGPoint(x: center.x, y: center.y - height / 2 + r)
    let path = CGMutablePath()
    // Tangent points from the tip to the circle.
    let d = tip.y - c.y
    let angle = asin(r / d)
    let t = sqrt(d * d - r * r)
    let left = CGPoint(x: tip.x - t * sin(angle), y: tip.y - t * cos(angle))
    let right = CGPoint(x: tip.x + t * sin(angle), y: tip.y - t * cos(angle))
    path.move(to: tip)
    path.addLine(to: right)
    let startAngle = atan2(right.y - c.y, right.x - c.x)
    let endAngle = atan2(left.y - c.y, left.x - c.x)
    path.addArc(center: c, radius: r, startAngle: startAngle, endAngle: endAngle, clockwise: true)
    path.closeSubpath()

    ctx.saveGState()
    ctx.addPath(path)
    ctx.setFillColor(fill)
    ctx.fillPath()
    if waterline {
        ctx.addPath(path)
        ctx.clip()
        ctx.setFillColor(mintDeep)
        ctx.fill(CGRect(x: center.x - height, y: center.y - height, width: height * 2, height: height * 0.62))
        // A soft highlight so it reads as liquid.
        ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.22))
        ctx.fillEllipse(in: CGRect(x: center.x - r * 0.55, y: center.y - r * 0.2, width: r * 0.35, height: r * 0.7))
    }
    ctx.restoreGState()
}

func roundedRect(_ ctx: CGContext, _ rect: CGRect, _ radius: CGFloat, _ color: CGColor) {
    let path = CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil)
    ctx.addPath(path)
    ctx.setFillColor(color)
    ctx.fillPath()
}

func drawText(_ ctx: CGContext, _ text: String, at point: CGPoint, size: CGFloat, color: CGColor, weight: NSFont.Weight = .bold) {
    let font = NSFont.systemFont(ofSize: size, weight: weight)
    let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: NSColor(cgColor: color)!]
    let line = CTLineCreateWithAttributedString(NSAttributedString(string: text, attributes: attrs))
    ctx.saveGState()
    ctx.textPosition = point
    CTLineDraw(line, ctx)
    ctx.restoreGState()
}

let root = FileManager.default.currentDirectoryPath

// App icon: 1024, no rounded corners (iOS masks it).
do {
    let ctx = context(1024, 1024)
    ctx.setFillColor(navy)
    ctx.fill(CGRect(x: 0, y: 0, width: 1024, height: 1024))
    drawDrop(ctx, center: CGPoint(x: 512, y: 500), height: 640, fill: mint, waterline: true)
    save(ctx, "\(root)/Damp/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png")
}

// Profile pictures (rounded, padded for circular crops).
for size in [1024, 400] {
    let s = CGFloat(size)
    let ctx = context(size, size)
    roundedRect(ctx, CGRect(x: 0, y: 0, width: s, height: s), s * 0.22, navy)
    drawDrop(ctx, center: CGPoint(x: s / 2, y: s * 0.5), height: s * 0.5, fill: mint, waterline: true)
    save(ctx, "\(root)/docs/brand/profile-\(size).png")
}

// Banner 1500x500 for X / YouTube.
do {
    let ctx = context(1500, 500)
    ctx.setFillColor(navy)
    ctx.fill(CGRect(x: 0, y: 0, width: 1500, height: 500))
    drawDrop(ctx, center: CGPoint(x: 260, y: 250), height: 300, fill: mint, waterline: true)
    drawText(ctx, "Damp", at: CGPoint(x: 460, y: 250), size: 120, color: white)
    drawText(ctx, "Drink less. Not never.", at: CGPoint(x: 466, y: 165), size: 46, color: CGColor(red: 1, green: 1, blue: 1, alpha: 0.62), weight: .semibold)
    save(ctx, "\(root)/docs/brand/banner-1500x500.png")
}

// First post image: the reveal number, square.
do {
    let ctx = context(1080, 1080)
    ctx.setFillColor(navy)
    ctx.fill(CGRect(x: 0, y: 0, width: 1080, height: 1080))
    roundedRect(ctx, CGRect(x: 90, y: 90, width: 900, height: 900), 80, surface)
    drawDrop(ctx, center: CGPoint(x: 170, y: 880), height: 90, fill: mint, waterline: true)
    drawText(ctx, "Damp", at: CGPoint(x: 230, y: 860), size: 54, color: CGColor(red: 1, green: 1, blue: 1, alpha: 0.62), weight: .semibold)
    drawText(ctx, "10 drinks a week is", at: CGPoint(x: 150, y: 640), size: 60, color: white, weight: .semibold)
    drawText(ctx, "$4,160", at: CGPoint(x: 150, y: 470), size: 200, color: CGColor(red: 0.98, green: 0.45, blue: 0.40, alpha: 1))
    drawText(ctx, "a year. Four dry nights", at: CGPoint(x: 150, y: 360), size: 60, color: white, weight: .semibold)
    drawText(ctx, "a week gives you", at: CGPoint(x: 150, y: 290), size: 60, color: white, weight: .semibold)
    drawText(ctx, "$2,377 back.", at: CGPoint(x: 150, y: 170), size: 110, color: mint)
    save(ctx, "\(root)/docs/brand/post-reveal.png")
}
