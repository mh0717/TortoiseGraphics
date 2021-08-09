import Foundation

extension Speed {

    var isNoAnimation: Bool {
        return velocity == 0
    }

    func movementDuration(distance: Double) -> CFTimeInterval {
        guard velocity != 0 else { return 0 }
        return CFTimeInterval(Double(distance) / (Double(velocity) * 100.0))
    }

    func animationDuration() -> CFTimeInterval {
        guard velocity != 0 else { return 0 }
        return CFTimeInterval(1.0 / Double(velocity))
    }

    private var velocity: UInt8 {
        if (self < 0) {return 0}
        if (self > 10) {return 10}
        return UInt8(self)
    }

}
