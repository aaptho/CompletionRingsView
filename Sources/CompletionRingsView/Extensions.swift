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
extension CGColor {
    static let extendedSrgb = CGColorSpace(name: CGColorSpace.extendedSRGB)!
    
    static func lerp(from: CGColor, to: CGColor, value: CGFloat) -> CGColor {
        // Performs the calculations in extended SRGB to match the behavior of the gradient
        // We convert back to the original color space at the end
        
        let fromComponents = from.converted(to: extendedSrgb, intent: .defaultIntent, options: nil)!.components!
        let toComponents = to.converted(to: extendedSrgb, intent: .defaultIntent, options: nil)!.components!
        let componentCount = from.numberOfComponents
        
        let clampedValue = max(0, min(value, 1))
        var components: [CGFloat] = .init(repeating: 0, count: componentCount)
        
        for i in 0 ..< componentCount {
            components[i] = CGFloat.lerp(from: fromComponents[i], to: toComponents[i], value: clampedValue)
        }
        
        let lerpedColor = CGColor(colorSpace: extendedSrgb, components: components)!
        
        return lerpedColor.converted(to: from.colorSpace ?? extendedSrgb, intent: .defaultIntent, options: nil)!
    }
}
