import CoreGraphics

extension Shape {

    func toCGPath() -> CGPath {
        return path.toCGPath()
    }

}

extension Shape.Path {

    func toCGPath() -> CGPath {
        switch self {
        case .points(let points):
            return points.toCGPath()
        case .ellipse(let rect):
            return CGPath(ellipseIn: CGRect(origin: rect.origin.toCGPoint(),
                                            size: rect.size.toCGSize()),
                          transform: nil)
        case .rect(let rect):
            return CGPath(rect: CGRect(origin: rect.origin.toCGPoint(),
                                       size: rect.size.toCGSize()),
                          transform: nil)
        }
    }

    static func arrowPath() -> Shape.Path {
        return .points([
            Vec2D( 0.00, 0.00),
            Vec2D( 0.50, -0.70),
            Vec2D( 0.00, -0.70),
            Vec2D( 0.00, -1.00),
            Vec2D( 0.00, -0.70),
            Vec2D(-0.50, -0.70)
        ].map({Vec2D($0.y, $0.x)}))
    }

    static func tortoisePath() -> Shape.Path {
        let side1: [Vec2D] = [
            Vec2D( 0.00, 0.75),
            Vec2D( 0.12, 0.63),
            Vec2D( 0.06, 0.39),
            Vec2D( 0.24, 0.18),
            Vec2D( 0.42, 0.30),
            Vec2D( 0.54, 0.24),
            Vec2D( 0.36, 0.06),
            Vec2D( 0.42, -0.18),
            Vec2D( 0.30, -0.42),
            Vec2D( 0.48, -0.60),
            Vec2D( 0.36, -0.75),
            Vec2D( 0.24, -0.54),
            Vec2D( 0.00, -0.66)
        ]
        let side2 = side1.map { Vec2D(-$0.x, $0.y) }.reversed()
        let side = (side1 + side2).map { Vec2D($0.y, $0.x)}
        return  .points(side)
        
    }

    static func circlePath() -> Shape.Path {
        return .ellipse(Shape.Rect(origin: Vec2D(-0.5, -0.5), size: Vec2D(1, 1)))
    }

    static func squarePath() -> Shape.Path {
        return .rect(Shape.Rect(origin: Vec2D(-0.5, -0.5), size: Vec2D(1, 1)))
    }

    static func trianglePath() -> Shape.Path {
        let y = cos(Double.pi / 6)
        return .points([Vec2D(0, 0), Vec2D(0.5, -y), Vec2D(-0.5, -y)])
    }

    static func classicPath() -> Shape.Path {
        return .points([Vec2D(0, 0), Vec2D(0.5, -1), Vec2D(0, -0.75), Vec2D(-0.5, -1)])
    }

}
