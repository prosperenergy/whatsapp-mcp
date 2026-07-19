import AppKit
import CoreImage
import Foundation

guard CommandLine.arguments.count == 2 else {
    fputs("usage: show-pairing-qr.swift <qr-text-file>\n", stderr)
    exit(2)
}

let qrTextPath = CommandLine.arguments[1]

final class PairingWindowController {
    private let window: NSWindow
    private let imageView = NSImageView()
    private let statusLabel = NSTextField(labelWithString: "Waiting for a fresh WhatsApp pairing code…")
    private var lastCode = ""

    init() {
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 640, height: 720),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false,
        )
        window.title = "Prosper WhatsApp Pairing"
        window.isReleasedWhenClosed = false

        let content = NSView(frame: window.contentView?.bounds ?? .zero)
        content.autoresizingMask = [.width, .height]
        window.contentView = content

        statusLabel.alignment = .center
        statusLabel.font = NSFont.systemFont(ofSize: 15, weight: .medium)
        statusLabel.frame = NSRect(x: 24, y: 672, width: 592, height: 24)
        statusLabel.autoresizingMask = [.width, .minYMargin]
        content.addSubview(statusLabel)

        imageView.imageScaling = .scaleProportionallyUpOrDown
        imageView.frame = NSRect(x: 20, y: 20, width: 600, height: 640)
        imageView.autoresizingMask = [.width, .height]
        content.addSubview(imageView)

        window.center()
        window.makeKeyAndOrderFront(nil)
    }

    func refresh() {
        guard let rawCode = try? String(contentsOfFile: qrTextPath, encoding: .utf8) else {
            statusLabel.stringValue = "Waiting for the local WhatsApp bridge to issue a pairing code…"
            return
        }
        let code = rawCode.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !code.isEmpty else {
            statusLabel.stringValue = "Waiting for a fresh WhatsApp pairing code…"
            return
        }
        guard code != lastCode else { return }
        guard let image = makeQRCodeImage(code) else {
            statusLabel.stringValue = "Unable to render the current pairing code."
            return
        }
        lastCode = code
        imageView.image = image
        statusLabel.stringValue = "Open WhatsApp on your phone → Settings → Linked Devices → Link a Device"
    }
}

func makeQRCodeImage(_ code: String) -> NSImage? {
    guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
    filter.setValue(Data(code.utf8), forKey: "inputMessage")
    filter.setValue("M", forKey: "inputCorrectionLevel")
    guard let output = filter.outputImage else { return nil }
    let scaled = output.transformed(by: CGAffineTransform(scaleX: 12, y: 12))
    let context = CIContext(options: nil)
    guard let cgImage = context.createCGImage(scaled, from: scaled.extent) else { return nil }
    return NSImage(cgImage: cgImage, size: NSSize(width: scaled.extent.width, height: scaled.extent.height))
}

let app = NSApplication.shared
app.setActivationPolicy(.regular)
let controller = PairingWindowController()
controller.refresh()
Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in controller.refresh() }
app.activate(ignoringOtherApps: true)
app.run()
