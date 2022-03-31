//  File.swift
//
//  Created by Aaron Thompson on 3/30/22.
//

import SwiftUI

extension CGRect {
    var center: CGPoint {
        return CGPoint(x: (maxX - minX) / 2, y: (maxY - minY) / 2)
    }
}

extension CGFloat {
    static func lerp(from: CGFloat, to: CGFloat, value: CGFloat) -> CGFloat {
        return from * value + to * (1 - value)
    }
    
    static func clamp(_ value: CGFloat) -> CGFloat {
        return Swift.min(Swift.max(value, 0), 1)
    }
    
    static func smoothStep(left: CGFloat, right: CGFloat, x: CGFloat) -> CGFloat {
        return clamp((x - left) / (right - left))
    }
}

@available(macCatalyst 15.0, iOS 13.0, *)
extension GeometryProxy {
    var center: CGPoint {
        CGPoint(x: size.width / 2, y: size.height / 2)
    }
}

@available(macCatalyst 15.0, iOS 15.0, *)
extension Color {
    static func lerp(from: Color, to: Color, value: CGFloat) -> Color {
        let fromCg = from.cgColor!
        let toCg = to.cgColor!
        let fromComponents = fromCg.components!
        let toComponents = toCg.components!
        let colorSpace = fromCg.colorSpace!
        let cappedValue = max(0, min(value, 1))
        
        var components: [CGFloat] = .init(repeating: 0, count: colorSpace.numberOfComponents + 1)
        
        for i in 0 ..< colorSpace.numberOfComponents + 1 {
            components[i] = CGFloat.lerp(from: fromComponents[i], to: toComponents[i], value: cappedValue)
        }
        
        return Color(cgColor: CGColor(colorSpace: colorSpace, components: components)!)
    }
}

@available(macCatalyst 15.0, iOS 15.0, *)
extension CGColor {
    static func lerp(from: CGColor, to: CGColor, value: CGFloat) -> CGColor {
        let fromComponents = from.components!
        let toComponents = to.components!
        let colorSpace = from.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)!
        let cappedValue = max(0, min(value, 1))
        
        var components: [CGFloat] = .init(repeating: 0, count: colorSpace.numberOfComponents + 1)
        
        for i in 0 ..< colorSpace.numberOfComponents + 1 {
            components[i] = CGFloat.lerp(from: fromComponents[i], to: toComponents[i], value: cappedValue)
        }
        
        return CGColor(colorSpace: colorSpace, components: components)!
    }
}
