//
//  Tortoise.swift
//  TortoiseGraphics
//
//  Created by Tomoki Kobayashi on 2019/07/15.
//

import Foundation
import CoreGraphics

public class Tortoise {

    public init(canvas: Canvas) {
        self.canvas = canvas
    }

    // MARK: - [Motion] Move and Draw

    public func forward(_ distance: Double) {
        let transform = CGAffineTransform(translationX: state.position.x, y: state.position.y)
            .rotated(by: -state.heading.radian.value)
        let newPosition = CGPoint(x: 0, y: distance).applying(transform)

        if state.isPenDown {
            let path = [state.position, newPosition]
            pathDrawable?.strokePath(path: path, color: state.penColor, lineWidth: state.penSize)
            state.fillPath?.append(newPosition)
        }

        state.position = newPosition
    }

    public func backword(_ distance: Double) {
        forward(-distance)
    }

    public func right(_ angle: Double) {
        state.heading = Degree(state.heading.value + CGFloat(angle))
    }

    public func left(_ angle: Double) {
        right(-angle)
    }

    public func setPosition(_ x: Double, _ y: Double) {
        // TODO: impl
    }

    public func setPos(_ x: Double, _ y: Double) {
        // TODO: impl
    }

    public func goto(_ x: Double, _ y: Double) {
        // TODO: impl
    }

    public func setX(_ x: Double) {
        // TODO: impl
    }

    public func setY(_ y: Double) {
        // TODO: impl
    }

    public func setHeading(_ heading: Double) {
        // TODO: impl
    }

    public func setH(_ heading: Double) {
        // TODO: impl
    }

    public func home() {
        // TODO: impl
    }

    public func dot(_ size: Double? = nil) {
        // TODO: impl
    }

    public func circle(_ radius: Double, _ extent: Double = 360, _ steps: Int = 0) {
        // TODO: impl
    }

    public func `repeat`(_ times: Int, _ block: () -> Void) {
        // TODO: impl
    }

    // MARK: - [Motion] Tell tortoise's state

    public var position: Vec2D {
        return Vec2D(Double(state.position.x), Double(state.position.y))
    }

    public var pos: Vec2D {
        return position
    }

    public func towards(_ x: Double, _ y: Double) -> Double {
        let tan = CGFloat((y - Double(state.position.y)) / (x - Double(state.position.x)))
        return 90 - Double(Radian(atan(tan)).degree.value)
    }

    public func towards(_ position: Vec2D) -> Double {
        return towards(position.x, position.y)
    }

    public var xcor: Double {
        return Double(state.position.x)
    }

    public var ycor: Double {
        return Double(state.position.y)
    }

    public var heading: Double {
        return Double(state.heading.value)
    }

    public func distance(_ x: Double, _ y: Double) -> Double {
        let distanceX = x - Double(state.position.x)
        let distanceY = y - Double(state.position.y)
        return sqrt(pow(distanceX, 2) + pow(distanceY, 2))
    }

    public func distance(_ position: Vec2D) -> Double {
        return distance(position.x, position.y)
    }

    public func random(_ max: Double) -> Double {
        let upperBound = UInt32(Swift.min(Swift.max(Int64(max), 0), Int64(UInt32.max)))
        return Double(arc4random_uniform(upperBound))
    }

    // MARK: - [Pen control] Drawing state

    public func penDown() {
        // TODO: impl
    }

    public func penUp() {
        // TODO: impl
    }

    public func penSize(_ size: Double) {
        // TODO: impl
    }

    public var isDown: Bool {
        return state.isPenDown
    }

    public var penSize: Double {
        return Double(state.penSize)
    }

    // MARK: - [Pen control] Color control

    public func penColor(_ color: Color) {
        // TODO: impl
    }

    public func penColor(_ r: Double, _ g: Double, _ b: Double) {
        // TODO: impl
        //add(command: CommandColor(.pen, red: CGFloat(r/255), green: CGFloat(g/255), blue: CGFloat(b/255)))
    }

    public func penColor(_ rgb: (r: Double, g: Double, b: Double)) {
        //add(command: CommandColor(.pen, red: CGFloat(rgb.r/255), green: CGFloat(rgb.g/255), blue: CGFloat(rgb.b/255)))
    }

    public var penColor: (r: Double, g: Double, b: Double) {
        let rgb = state.penColor.rgb
        return (r: Double(rgb.0*255), g: Double(rgb.1*255), b: Double(rgb.2*255))
    }

    public func fillColor(_ color: Color) {
        // TODO: impl
        //add(command: CommandColor(.fill, color: color))
    }

    public func fillColor(_ r: Double, _ g: Double, _ b: Double) {
        // TODO: impl
        //add(command: CommandColor(.fill, red: CGFloat(r/255), green: CGFloat(g/255), blue: CGFloat(b/255)))
    }

    public func fillColor(_ rgb: (r: Double, g: Double, b: Double)) {
        // TODO: impl
        //add(command: CommandColor(.fill, red: CGFloat(rgb.r/255), green: CGFloat(rgb.g/255), blue: CGFloat(rgb.b/255)))
    }

    public var fillColor: (r: Double, g: Double, b: Double) {
        let rgb = state.fillColor.rgb
        return (r: Double(rgb.0*255), g: Double(rgb.1*255), b: Double(rgb.2*255))
    }

    // MARK: - [Pen Control] Filling

    public var filling: Bool {
        return state.fillPath != nil
    }

    public func beginFill() {
        state.fillPath = [state.position]
    }

    public func endFill() {
        if let path = state.fillPath {
            pathDrawable?.fillPath(path: path, color: state.fillColor)
        }
        state.fillPath = nil
    }

    // MARK: - [Pen control] More drawing control

    public func reset() {
        // TODO: impl
    }

    public func clear() {
        // TODO: impl
    }

    // MARK: - [Tortoise state] Visiblity

    public func showTortoise() {
        // TODO: impl
    }

    public func hideTortoise() {
        // TODO: impl
    }

    public var isVisible: Bool {
        return state.isVisible
    }

    public func shape(_ shape: Shape) {
        // TODO: impl
    }

    public var shape: Shape {
        return state.shape
    }

    // MARK: - Internal

    var state: TortoiseState = TortoiseState()

    let canvas: Canvas

    var pathDrawable: PathDrawable? {
        return canvas as? PathDrawable
    }

}
