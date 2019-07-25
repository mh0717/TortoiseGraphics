import Foundation
import CoreGraphics

public class ImageCanvas: Canvas, TortoiseDelegate {

    public init(size: CGSize, scale: CGFloat = 1, color: Color? = nil) {
        self.size = size
        self.scale = scale
        self.color = color ?? Color.white
        self.context = createBitmapContext(size: size, scale: scale)
        self.context.translateBy(x: size.width * 0.5, y: size.height * 0.5)
    }

    public var cgImage: CGImage? {
        let bgContext = createBitmapContext(size: size, scale: scale)
        bgContext.setFillColor(color.cgColor)
        bgContext.fill(CGRect(origin: .zero, size: size))
        if let fgImage = context.makeImage() {
            bgContext.draw(fgImage, in: CGRect(origin: .zero, size: size))
        }
        return bgContext.makeImage()
    }

    // MARK: - Canvas

    public var size: CGSize

    public var scale: CGFloat

    public var color: Color

    // MARK: - TortoiseDelegate

    func initialized(_ state: TortoiseState) {
    }

    func positionChanged(_ state: TortoiseState, from position: CGPoint) {
        guard state.pen.isDown else { return }
        context.saveGState()
        context.setStrokeColor(state.pen.color)
        context.setFillColor(CGColor.clear)
        context.setLineWidth(state.pen.width)
        context.addPath([position, state.position].toCGPath())
        context.strokePath()
        context.restoreGState()
    }

    func headingChanged(_ state: TortoiseState, from heading: Angle) {
    }

    func penChanged(_ state: TortoiseState, from pen: Pen) {
    }

    func shapeChanged(_ state: TortoiseState, from shape: Shape) {
    }

    func fillRequested(_ state: TortoiseState) {
        guard let fillPath = state.fillPath else { return }
        context.saveGState()
        context.setStrokeColor(CGColor.clear)
        context.setFillColor(state.pen.fillColor)
        context.addPath(fillPath.toCGPath())
        context.fillPath()
        context.restoreGState()
    }

    // MARK: - Private

    private let context: CGContext

}

private func createBitmapContext(size: CGSize, scale: CGFloat) -> CGContext {
    let width = Int(size.width * scale)
    let height = Int(size.height * scale)
    let context = CGContext(data: nil,
                            width: width,
                            height: height,
                            bitsPerComponent: 8,
                            bytesPerRow: width * 4,
                            space: CGColorSpaceCreateDeviceRGB(),
                            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)!
    // swiftlint:disable:previous force_unwrapping
    context.scaleBy(x: scale, y: scale)
    return context
}
