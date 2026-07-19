import AppKit
import CoreImage
import Foundation

guard CommandLine.arguments.count == 3 else {
    fputs("usage: render-pairing-qr.swift <qr-text-file> <png-output>\n", stderr)
    exit(2)
}

let qrTextPath = CommandLine.arguments[1]
let pngPath = CommandLine.arguments[2]
let qrText = try String(contentsOfFile: qrTextPath, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)

guard !qrText.isEmpty else {
    fputs("pairing QR text is empty\n", stderr)
    exit(1)
}

guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
    fputs("QR generator is unavailable\n", stderr)
    exit(1)
}
filter.setValue(Data(qrText.utf8), forKey: "inputMessage")
filter.setValue("M", forKey: "inputCorrectionLevel")

guard let baseImage = filter.outputImage else {
    fputs("failed to create QR image\n", stderr)
    exit(1)
}

let image = baseImage.transformed(by: CGAffineTransform(scaleX: 12, y: 12))
let context = CIContext(options: nil)
guard let cgImage = context.createCGImage(image, from: image.extent) else {
    fputs("failed to render QR image\n", stderr)
    exit(1)
}

let bitmap = NSBitmapImageRep(cgImage: cgImage)
guard let png = bitmap.representation(using: NSBitmapImageRep.FileType.png, properties: [:]) else {
    fputs("failed to encode QR image\n", stderr)
    exit(1)
}

try png.write(to: URL(fileURLWithPath: pngPath), options: Data.WritingOptions.atomic)
try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: pngPath)
