#if os (iOS)
import UIKit

public class PlaygroundCanvas: UIView, Canvas, TortoiseDelegate {

    public init(size: Vec2D, color: Color? = nil) {
        self.canvasColor = color ?? .transparent
        self.imageCanvas = ImageCanvas(size: size, scale: Double(UIScreen.main.scale), color: self.canvasColor)
        super.init(frame: CGRect(origin: .zero, size: size.toCGSize()))
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if (self.bounds.size != self.imageCanvas.canvasSize.toCGSize()) {
            canvasDidLayout()
        }
    }

    // MARK: - Canvas

    public func add(_ tortoise: Tortoise) {
        guard tortoise.delegate !== self else { return }
        tortoise.delegate?.tortoiseDidAddToOtherCanvas(tortoise.uuid, tortoise.state)
        tortoise.delegate = self
        tortoiseDidInitialized(tortoise.uuid, tortoise.state)
    }

    public var canvasSize: Vec2D {
        return imageCanvas.canvasSize
    }

    public func canvasColor(_ r: Double, _ g: Double, _ b: Double) {
        let canvasColor = Color(r, g, b)
//        addEvent(.canvasDidChangeBackground(canvasColor))
//        layer.backgroundColor = canvasColor.cgColor
        self.canvasColor(canvasColor)
        
    }

    public func canvasColor(_ hex: String) {
        let canvasColor = Color(hex)
//        addEvent(.canvasDidChangeBackground(canvasColor))
//        layer.backgroundColor = canvasColor.cgColor
        self.canvasColor(canvasColor)
    }

    public func canvasColor(_ color: Color) {
        canvasColor = color
//        addEvent(.canvasDidChangeBackground(canvasColor))
        if (Thread.isMainThread) {
            
        }
        else {
            weak var wself = self
            DispatchQueue.main.sync {
                wself?.layer.backgroundColor = wself?.canvasColor.cgColor
            }
        }
        
    }

    public private(set) var canvasColor: Color

    // MARK: - TortoiseDelegate

    func tortoiseDidInitialized(_ uuid: UUID, _ state: TortoiseState) {
        addEvent(.tortoiseDidInitialize(uuid, state))
    }

    func tortoiseDidChangePosition(_ uuid: UUID, _ state: TortoiseState) {
        addEvent(.tortoiseDidChangePosition(uuid, state))
    }

    func tortoiseDidChangeHeading(_ uuid: UUID, _ state: TortoiseState) {
        addEvent(.tortoiseDidChangeHeading(uuid, state))
    }

    func tortoiseDidChangePen(_ uuid: UUID, _ state: TortoiseState) {
        addEvent(.tortoiseDidChangePen(uuid, state))
    }

    func tortoiseDidChangeShape(_ uuid: UUID, _ state: TortoiseState) {
        addEvent(.tortoiseDidChangeShape(uuid, state))
    }

    func tortoiseDidRequestToFill(_ uuid: UUID, _ state: TortoiseState) {
        addEvent(.tortoiseDidRequestToFill(uuid, state))
    }

    func tortoiseDidRequestToClear(_ uuid: UUID, _ state: TortoiseState) {
        addEvent(.tortoiseDidRequestToClear(uuid, state))
    }

    func tortoiseDidAddToOtherCanvas(_ uuid: UUID, _ state: TortoiseState) {
        addEvent(.tortoiseDidAddToOtherCanvas(uuid, state))
    }

    // MARK: - Internal

    func canvasDidLayout() {
        addEvent(.canvasDidLayout)
    }

    enum Event {
        case tortoiseDidInitialize(UUID, TortoiseState)
        case tortoiseDidChangePosition(UUID, TortoiseState)
        case tortoiseDidChangeHeading(UUID, TortoiseState)
        case tortoiseDidChangePen(UUID, TortoiseState)
        case tortoiseDidChangeShape(UUID, TortoiseState)
        case tortoiseDidRequestToFill(UUID, TortoiseState)
        case tortoiseDidRequestToClear(UUID, TortoiseState)
        case tortoiseDidAddToOtherCanvas(UUID, TortoiseState)
        case canvasDidChangeBackground(Color)
        case canvasDidLayout
        case canvasDidRequestReset(Color)
    }

    func addEvent(_ event: Event) {
        lock.lock()
        eventQueue.append(event)
        if isHandling {
            lock.unlock()
        } else {
            isHandling = true
            lock.unlock()
            handleNextEvent()
        }
    }

    // MARK: Private

    private let lock = NSLock()
    private var eventQueue: [Event] = []
    private var isHandling: Bool = false

    private var imageCanvas: ImageCanvas

    private struct TortoiseShape {
        var position: Vec2D
        var shapeLayer: CAShapeLayer
    }
    private var tortoiseShapeMap: [UUID: TortoiseShape] = [:]

    private func handleNextEvent() {
        lock.lock()
        let popped = eventQueue.isEmpty ? nil : eventQueue.removeFirst()
        if let popped = popped {
            lock.unlock()
            handleEvent(popped) { [weak self] in
                self?.handleNextEvent()
            }
        } else {
            isHandling = false
            lock.unlock()
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    private func handleEvent(_ event: Event, completion: @escaping () -> Void) {
        switch event {
        case .tortoiseDidInitialize(let uuid, let state):
            handleInitializeEvent(uuid, state, completion)
        case .tortoiseDidChangePosition(let uuid, let state):
            handleChangePositionEvent(uuid, state, completion)
        case .tortoiseDidChangeHeading(let uuid, let state):
            handleChangeHeadingEvent(uuid, state, completion)
        case .tortoiseDidChangePen(let uuid, let state):
            handleChangePenEvent(uuid, state, completion)
        case .tortoiseDidChangeShape(let uuid, let state):
            handleChangeShapeEvent(uuid, state, completion)
        case .tortoiseDidRequestToFill(let uuid, let state):
            handleRequestToFillEvent(uuid, state, completion)
        case .tortoiseDidRequestToClear(let uuid, let state):
            handleRequestToClearEvent(uuid, state, completion)
        case .tortoiseDidAddToOtherCanvas(let uuid, let state):
            handleAddToOtherCanvasEvent(uuid, state, completion)
        case .canvasDidChangeBackground(let color):
            handleChangeBackgroundEvent(color, completion)
        case .canvasDidLayout:
            handleLayoutEvent(completion)
        case .canvasDidRequestReset(let color):
            handleResetEvent(color, completion)
        }
    }

    private func handleInitializeEvent(_ uuid: UUID, _ state: TortoiseState, _ completion: @escaping () -> Void) {
        CATransaction.transactionWithoutAnimation({
            let shapeLayer = CAShapeLayer()
            layer.addSublayer(shapeLayer)
            tortoiseShapeMap[uuid] = TortoiseShape(position: state.position,
                                                   shapeLayer: shapeLayer)

            shapeLayer.position = translatedPosition(position: state.position.toCGPoint())
            shapeLayer.transform = rotatedTransform(angle: state.heading)
            shapeLayer.path = makeShapePath(shape: state.shape,
                                            penSize: CGFloat(state.pen.width))
            shapeLayer.strokeColor = state.pen.color.cgColor
            shapeLayer.lineWidth = CGFloat(state.pen.width)
            shapeLayer.fillColor = state.pen.fillColor.cgColor
        }, completion: { [weak self] in
            self?.layer.contents = self?.imageCanvas.cgImage
            completion()
        })
    }

    private func handleChangePositionEvent(_ uuid: UUID, _ state: TortoiseState, _ completion: @escaping () -> Void) {
        let shapeLayer = tortoiseShapeMap[uuid]?.shapeLayer
        let toPos = translatedPosition(position: state.position.toCGPoint())
        let fromPos = shapeLayer?.position ?? .zero
        let pathLayer = state.pen.isDown ? CAShapeLayer() : nil

        let completionBlock = { [weak self] in
            self?.imageCanvas.tortoiseDidChangePosition(uuid, state)
            self?.layer.contents = self?.imageCanvas.cgImage
            CATransaction.transactionWithoutAnimation({
                pathLayer?.removeAllAnimations()
                pathLayer?.removeFromSuperlayer()
                shapeLayer?.position = toPos
                shapeLayer?.removeAllAnimations()
            }, completion: completion)
        }

        if state.speed.isNoAnimation {
            completionBlock()
            return
        }

        let toPath = [fromPos, toPos].toCGPath()
        let fromPath = fromPos.toCGPath()
        let distance = Double(fromPos.distance(to: toPos))
        CATransaction.transaction({ [weak self] in
            let duration = state.speed.movementDuration(distance: distance)

            if let pathLayer = pathLayer {
                self?.layer.insertSublayer(pathLayer, at: 0)
                pathLayer.frame = CGRect(origin: .zero, size: .zero)
                pathLayer.path = fromPath
                pathLayer.backgroundColor = CGColor.clear
                pathLayer.strokeColor = state.pen.color.cgColor
                pathLayer.fillColor = CGColor.clear
                pathLayer.lineWidth = CGFloat(state.pen.width)

                let pathAnimation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.path))
                pathAnimation.toValue = toPath
                pathAnimation.duration = duration
                pathAnimation.fillMode = .forwards
                pathAnimation.isRemovedOnCompletion = false
                pathLayer.add(pathAnimation, forKey: "shape-path")
            }

            let shapeAnimation = CAKeyframeAnimation(keyPath: #keyPath(CAShapeLayer.position))
            shapeAnimation.path = toPath
            shapeAnimation.duration = duration
            shapeAnimation.fillMode = .forwards
            shapeAnimation.isRemovedOnCompletion = false
            shapeLayer?.add(shapeAnimation, forKey: "shape-position)")

        }, completion: completionBlock)
    }

    private func handleChangeHeadingEvent(_ uuid: UUID, _ state: TortoiseState, _ completion: @escaping () -> Void) {
        let shapeLayer = tortoiseShapeMap[uuid]?.shapeLayer
        let toTransform = rotatedTransform(angle: state.heading)

        let completionBlock = { [weak self] in
            self?.imageCanvas.tortoiseDidChangeHeading(uuid, state)
            self?.layer.contents = self?.imageCanvas.cgImage
            CATransaction.transactionWithoutAnimation({
                shapeLayer?.transform = toTransform
                shapeLayer?.removeAllAnimations()
            }, completion: completion)
        }

        if state.speed.isNoAnimation {
            completionBlock()
            return
        }

        CATransaction.transaction({
            let shapeAnimation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.transform))
            shapeAnimation.toValue = toTransform
            shapeAnimation.duration = state.speed.animationDuration()
            shapeAnimation.fillMode = .forwards
            shapeAnimation.isRemovedOnCompletion = false
            shapeLayer?.add(shapeAnimation, forKey: "shape-transform")
        }, completion: completionBlock)
    }

    private func handleChangePenEvent(_ uuid: UUID, _ state: TortoiseState, _ completion: @escaping () -> Void) {
        let shapeLayer = tortoiseShapeMap[uuid]?.shapeLayer
        let strokeColor = state.pen.color.cgColor
        let lineWidth = CGFloat(state.pen.width)
        let fillColor = state.pen.fillColor.cgColor

        let completionBlock = { [weak self] in
            CATransaction.transactionWithoutAnimation({
                shapeLayer?.strokeColor = strokeColor
                shapeLayer?.lineWidth = lineWidth
                shapeLayer?.fillColor = fillColor
                shapeLayer?.removeAllAnimations()
            }, completion: { [weak self] in
                self?.handleChangeShapeEvent(uuid, state, completion)
            })
        }

        if state.speed.isNoAnimation {
            completionBlock()
            return
        }

        CATransaction.transaction({
            let duration = state.speed.animationDuration()

            let anim1 = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.strokeColor))
            anim1.toValue = strokeColor
            let anim2 = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.lineWidth))
            anim2.toValue = lineWidth
            let anim3 = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.fillColor))
            anim3.toValue = fillColor

            let animGroup = CAAnimationGroup()
            animGroup.animations = [anim1, anim2, anim3]
            animGroup.duration = duration
            animGroup.fillMode = .forwards
            animGroup.isRemovedOnCompletion = false

            shapeLayer?.add(animGroup, forKey: "shape-color")

        }, completion: completionBlock)
    }

    private func handleChangeShapeEvent(_ uuid: UUID, _ state: TortoiseState, _ completion: @escaping () -> Void) {
        let shapeLayer = tortoiseShapeMap[uuid]?.shapeLayer

        let toPath = makeShapePath(shape: state.shape, penSize: CGFloat(state.pen.width))
        let toOpacity: Float = state.isVisible ? 1 : 0

        let completionBlock = { [weak self] in
            self?.imageCanvas.tortoiseDidChangeShape(uuid, state)
            self?.layer.contents = self?.imageCanvas.cgImage
            CATransaction.transactionWithoutAnimation({
                shapeLayer?.path = toPath
                shapeLayer?.opacity = toOpacity
                shapeLayer?.removeAllAnimations()
            }, completion: completion)
        }

        if state.speed.isNoAnimation {
            completionBlock()
            return
        }

        CATransaction.transaction({
            let duration = state.speed.animationDuration()

            let anim1 = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.path))
            anim1.toValue = toPath

            let anim2 = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.opacity))
            anim2.toValue = toOpacity

            let animGroup = CAAnimationGroup()
            animGroup.animations = [anim1, anim2]
            animGroup.duration = duration
            animGroup.fillMode = .forwards
            animGroup.isRemovedOnCompletion = false

            shapeLayer?.add(animGroup, forKey: "shape-path")

        }, completion: completionBlock)
    }

    private func handleRequestToFillEvent(_ uuid: UUID, _ state: TortoiseState, _ completion: @escaping () -> Void) {
        guard let fillPath = state.fillPath else { completion(); return }
        let toPath = translatedPath(path: fillPath.toCGPath())
        var fillLayer: CAShapeLayer?

        let completionBlock = { [weak self] in
            self?.imageCanvas.tortoiseDidRequestToFill(uuid, state)
            self?.layer.contents = self?.imageCanvas.cgImage
            CATransaction.transactionWithoutAnimation({
                fillLayer?.removeAllAnimations()
                fillLayer?.removeFromSuperlayer()
            }, completion: completion)
        }

        if state.speed.isNoAnimation {
            completionBlock()
            return
        }

        fillLayer = CAShapeLayer()
        CATransaction.transaction({ [weak self] in
            if let fillLayer = fillLayer {
                self?.layer.addSublayer(fillLayer)
                fillLayer.frame = CGRect(origin: .zero, size: .zero)
                fillLayer.opacity = 0
                fillLayer.path = toPath
                fillLayer.backgroundColor = CGColor.clear
                fillLayer.strokeColor = CGColor.clear
                fillLayer.fillColor = state.pen.fillColor.cgColor
                fillLayer.fillRule = .evenOdd

                let animation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.opacity))
                animation.toValue = 1
                animation.duration = state.speed.animationDuration()
                animation.fillMode = .forwards
                animation.isRemovedOnCompletion = false

                fillLayer.add(animation, forKey: "fill-path")
            }
        }, completion: completionBlock)
    }

    private func handleRequestToClearEvent(_ uuid: UUID, _ state: TortoiseState, _ completion: @escaping () -> Void) {
        imageCanvas.tortoiseDidRequestToClear(uuid, state)
        layer.contents = imageCanvas.cgImage
        completion()
    }

    private func handleAddToOtherCanvasEvent(_ uuid: UUID, _ state: TortoiseState, _ completion: @escaping () -> Void) {
        if let shapeLayer = tortoiseShapeMap[uuid]?.shapeLayer {
            shapeLayer.removeFromSuperlayer()
            tortoiseShapeMap[uuid] = nil
        }
        completion()
    }

    private func handleChangeBackgroundEvent(_ color: Color, _ completion: () -> Void) {
        imageCanvas.canvasColor(color)
        if (Thread.isMainThread) {
            layer.contents = imageCanvas.cgImage
        }
        else {
//            layer.contents = imageCanvas.cgImage
            weak var wself = self
            DispatchQueue.main.sync {
                wself?.layer.contents = wself?.imageCanvas.cgImage
            }
        }
       
        completion()
    }

    private func handleLayoutEvent(_ completion: @escaping () -> Void) {
        let oldSize = imageCanvas.canvasSize.toCGSize()
        let newSize = bounds.size
        print(oldSize)
        print(newSize)
        let newCanvas = ImageCanvas(size: Vec2D(size: newSize),
                                    scale: Double(UIScreen.main.scale),
                                    color: canvasColor)
        if let oldImage = imageCanvas.cgImage {
            let drawRect = CGRect(x: (/*newSize.width*/0 - oldSize.width) * 0.5,
                                  y: (/*newSize.height*/0 - oldSize.height) * 0.5,
                                  width: oldSize.width,
                                  height: oldSize.height)
            newCanvas.drawImage(oldImage, in: drawRect)
        }
        imageCanvas = newCanvas
        layer.contents = imageCanvas.cgImage

        CATransaction.transactionWithoutAnimation({ [weak self] in
            guard let self = self else { return }
            for shape in self.tortoiseShapeMap.values {
                let toPos = translatedPosition(position: shape.position.toCGPoint())
                shape.shapeLayer.position = toPos
            }
        }, completion: completion)
    }

    private func handleResetEvent(_ canvasColor: Color, _ completion: @escaping () -> Void) {
        imageCanvas = ImageCanvas(size: imageCanvas.canvasSize,
                                  scale: Double(UIScreen.main.scale),
                                  color: canvasColor)
        layer.contents = imageCanvas.cgImage
        tortoiseShapeMap.forEach {
            $0.value.shapeLayer.removeFromSuperlayer()
        }
        tortoiseShapeMap.removeAll()
        completion()
    }

    private func makePositionTransform() -> CGAffineTransform {
        return CGAffineTransform(
            translationX: CGFloat(canvasSize.x * 0.5), y: CGFloat(canvasSize.y * 0.5)
            ).scaledBy(x: 1, y: -1)
    }

    private func translatedPosition(position: CGPoint) -> CGPoint {
        return position.applying(makePositionTransform())
    }

    private func translatedPath(path: CGPath) -> CGPath {
        var transform = makePositionTransform()
        return path.copy(using: &transform) ?? path
    }

    private func rotatedTransform(angle: Angle) -> CATransform3D {
        return CATransform3DMakeRotation(CGFloat(angle.radian), 0, 0, 1)
    }

    private func makeShapePath(shape: Shape, penSize: CGFloat) -> CGPath {
        let scale = 10 + penSize * 2
        let transform = CGAffineTransform(scaleX: scale, y: -scale)
        let shapePath = CGMutablePath()
        shapePath.addPath(shape.toCGPath(), transform: transform)
        shapePath.closeSubpath()
        return shapePath
    }

}
#endif
