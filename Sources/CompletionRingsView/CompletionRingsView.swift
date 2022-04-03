//  RingsView.swift
//
//  Created by Aaron Thompson on 3/26/22.
//

import SwiftUI

@available(macCatalyst 15.0, iOS 15.0, *)
public struct Ring: Equatable {
    /// A value of 1.0 represents 100% complete; may be > 100%
    public var completion: CGFloat
    public let startColor: CGColor
    public let endColor: CGColor
    /// (Optional) An icon to be displayed at the top-middle of this ring
    public let icon: Image?
    
    fileprivate let id = UUID()
    
    public init(
        completion: CGFloat,
        startColor: CGColor,
        endColor: CGColor,
        icon: Image? = nil
    ) {
        self.completion = completion
        self.startColor = startColor
        self.endColor = endColor
        self.icon = icon
    }
}

/// Draws a single completion ring
@available(macCatalyst 15.0, iOS 15.0, *)
public struct CompletionRingView: View {
    public let ring: Ring
    public let ringThickness: CGFloat?
    
    public init(ring: Ring, ringThickness: CGFloat? = nil) {
        self.ring = ring
        self.ringThickness = ringThickness
    }
    
    public var body: some View {
        Rectangle()
            .foregroundColor(.clear)
            .modifier(CompletionRingViewModifier(ring: ring, ringThickness: ringThickness))
    }
}

/// Draws nested completion rings
@available(macCatalyst 15.0, iOS 15.0, *)
public struct CompletionRingsView: View {
    public let rings: [Ring]
    public let ringThickness: CGFloat
    public let ringSpacing: CGFloat
    
    public init(rings: [Ring], ringThickness: CGFloat, ringSpacing: CGFloat) {
        self.rings = rings
        self.ringThickness = ringThickness
        self.ringSpacing = ringSpacing
    }
    
    public var body: some View {
        ZStack {
            ForEachWithIndex(rings, id: \.id) { ring, index in
                CompletionRingView(ring: ring, ringThickness: ringThickness)
                    .padding(CGFloat(index) * (ringThickness + ringSpacing))
            }
        }
    }
}

@available(macCatalyst 15.0, iOS 15.0, *)
private struct InnerCompletionRingView: View {
    let ring: Ring
    let ringThickness: CGFloat?
    
    init(ring: Ring, ringThickness: CGFloat? = nil) {
        self.ring = ring
        self.ringThickness = ringThickness
    }
    
    var body: some View {
        // There is an aliasing artifact where the start and end caps meet the ring,
        // so back it up by this small amount to avoid this gap
        let capAliasingCoverup = Angle(radians: 0.006)
        
        let completion = max(0, ring.completion) + capAliasingCoverup.degrees / 360
        let startColor = ring.startColor
        let endColor = ring.endColor
        
        let startAngle = Angle.zero
        let endAngle = Angle(degrees: completion * 360.0)
        
        let wrappedEndAngle = Angle(degrees: CGFloat(fmod(endAngle.degrees, 360)))
        let baseGradientStartColor = Color(endAngle.degrees < 720 ? startColor : endColor)
        let endCapColor = Color(CGColor.lerp(from: startColor, to: endColor, value: 1 - endAngle.degrees / 360))
        
        return GeometryReader { geometry in
            let ringThickness = ringThickness ?? geometry.size.width / 8
            let halfRingThickness: CGFloat = ringThickness / 2
            let iconSize = ringThickness * 0.75
            let radius: CGFloat = geometry.size.width / 2 - halfRingThickness
            let startPoint: CGPoint = CGPoint(
                x: geometry.center.x + radius * cos(CGFloat(startAngle.radians)),
                y: geometry.center.y + radius * sin(CGFloat(startAngle.radians))
            )
            let endPoint: CGPoint = CGPoint(
                x: geometry.center.x + radius * CGFloat(cos((endAngle - capAliasingCoverup).radians)),
                y: geometry.center.y + radius * CGFloat(sin((endAngle - capAliasingCoverup).radians))
            )
            // Fade in the end cap shadow from 90% completion to 100% completion
            let finalEndCapShadowOpacity: CGFloat = 1
            let endCapShadowOpacity: CGFloat = finalEndCapShadowOpacity * CGFloat.smoothStep(left: 0.9, right: 1.0, x: completion)
            let endCapShadowRadius: CGFloat = halfRingThickness / 4
            
            // Base track
            Circle().stroke(Color(startColor).opacity(0.25), lineWidth: ringThickness).padding(halfRingThickness)
            
            // Start cap
            Path { path in
                path.addArc(
                    center: startPoint,
                    radius: 0,
                    startAngle: .degrees(0),
                    endAngle: .degrees(180),
                    clockwise: false
                )
            }.stroke(Color(startColor), style: StrokeStyle(
                lineWidth: ringThickness,
                lineCap: CGLineCap.round
            ))
            
            // Base gradient
            Path { path in
                path.addArc(
                    center: geometry.center,
                    radius: radius,
                    startAngle: startAngle + capAliasingCoverup,
                    endAngle: endAngle,
                    clockwise: false
                )
            }
            .stroke(
                .conicGradient(
                    colors: [baseGradientStartColor, Color(endColor)],
                    center: UnitPoint.center,
                    angle: Angle.degrees(0)
                ),
                style: StrokeStyle(
                    lineWidth: ringThickness,
                    lineCap: CGLineCap.butt
                )
            )
            
            // Overfilled gradient
            if endAngle.degrees > 360 {
                Path { path in
                    path.addArc(
                        center: geometry.center,
                        radius: radius,
                        startAngle: startAngle - capAliasingCoverup,
                        endAngle: wrappedEndAngle,
                        clockwise: false
                    )
                }
                .stroke(
                    Color(endColor),
                    style: StrokeStyle(
                        lineWidth: ringThickness,
                        lineCap: CGLineCap.butt
                    )
                )
            }
            
            // End cap shadow
            // Has to be drawn separately from the end cap to avoid aliasing artifacts at the seam
            Path { path in
                path.addArc(
                    center: endPoint,
                    radius: halfRingThickness - 0.1,
                    startAngle: .degrees(0),
                    endAngle: .degrees(180),
                    clockwise: true,
                    transform: CGAffineTransform.identity
                        // Rotate to match the angle of the end cap
                        .translatedBy(x: endPoint.x, y: endPoint.y)
                        .rotated(by: endAngle.radians + .pi)
                        .translatedBy(x: -endPoint.x, y: -endPoint.y)
                )
            }
            .fill(endCapColor)
            .shadow(color: Color(white: 0, opacity: endCapShadowOpacity), radius: endCapShadowRadius)
            // Clipped to only the clockwise side
            .clipShape(Path { path in
                path.addArc(
                    center: geometry.center,
                    radius: radius,
                    startAngle: endAngle,
                    endAngle: endAngle + .degrees(180),
                    clockwise: false
                )
            }.stroke(lineWidth: ringThickness))
            
            // End cap
            Path { path in
                path.addArc(
                    center: endPoint,
                    radius: halfRingThickness,
                    startAngle: .degrees(0),
                    endAngle: .degrees(180),
                    clockwise: true,
                    transform: CGAffineTransform.identity
                        // Rotate to match the angle of the end cap
                        .translatedBy(x: endPoint.x, y: endPoint.y)
                        .rotated(by: endAngle.radians + .pi)
                        .translatedBy(x: -endPoint.x, y: -endPoint.y)
                )
            }
            .fill(endCapColor)
            
            if let icon = ring.icon {
                icon
                    .resizable(capInsets: EdgeInsets(), resizingMode: Image.ResizingMode.stretch)
                    .aspectRatio(contentMode: SwiftUI.ContentMode.fit)
                    .rotationEffect(.degrees(90))
                    .position(x: startPoint.x, y: startPoint.y)
                    .frame(width: iconSize, height: iconSize)
            }
        }
        .rotationEffect(.degrees(270))
        .drawingGroup()
    }
}

/// This AnimatableModifier effectively allows us to bypass the animation system's
/// default interpolation and re-submit with every frame; without it, the ring paths
/// and colors don't cleanly interpolate between start and end states, so they end up
/// cross-fading improperly.
/// The base gradient start color is one example where we actually want to snap
/// between the possible colors instead of fading.
@available(macCatalyst 15.0, iOS 15.0, *)
private struct CompletionRingViewModifier: AnimatableModifier {
    var ring: Ring
    let ringThickness: CGFloat?
    
    func body(content: Content) -> some View {
        return content.overlay(InnerCompletionRingView(ring: ring, ringThickness: ringThickness))
    }
    
    var animatableData: CGFloat {
        get { ring.completion }
        set { ring.completion = newValue }
    }
}

@available(macCatalyst 15.0, iOS 15.0, *)
struct RingsView_Previews: PreviewProvider {
    struct PreviewWithSlider: View {
        @State private var sliderValue: CGFloat = 1.5
        
        var body: some View {
            VStack {
                CompletionRingView(ring: Ring(
                    completion: sliderValue,
                    startColor: CGColor(red: 0.0 / 255, green: 120.0 / 255, blue: 221.0 / 255, alpha: 1),
                    endColor: CGColor(red: 239.0 / 255, green: 072.0 / 255, blue: 120.0 / 255, alpha: 1)
                ), ringThickness: 80)
                .aspectRatio(contentMode: SwiftUI.ContentMode.fit)
                
                Slider(value: $sliderValue, in: 0.0 ... 2.5)
            }
            .padding(20)
        }
    }
    
    struct MultipleRingPreview: View {
        let rings: [Ring] = [
            Ring(
                completion: 0.5,
                startColor: CGColor(red: 225.0 / 255, green:   1.0 / 255, blue:  22.0 / 255, alpha: 1),
                endColor:   CGColor(red: 255.0 / 255, green:  51.0 / 255, blue: 139.0 / 255, alpha: 1),
                icon: Image(systemName: "flame.fill")
            ),
            Ring(
                completion: 0.5,
                startColor: CGColor(red:  57.0 / 255, green: 219.0 / 255, blue:   0.0 / 255, alpha: 1),
                endColor:   CGColor(red: 187.0 / 255, green: 255.0 / 255, blue:   0.0 / 255, alpha: 1),
                icon: Image(systemName: "figure.walk.circle.fill")
            ),
            Ring(
                completion: 0.5,
                startColor: CGColor(red:   0.0 / 255, green: 186.0 / 255, blue: 233.0 / 255, alpha: 1),
                endColor:   CGColor(red:  15.0 / 255, green: 253.0 / 255, blue: 207.0 / 255, alpha: 1),
                icon: Image(systemName: "figure.wave.circle.fill")
            )
        ]
        
        var body: some View {
            CompletionRingsView(rings: rings, ringThickness: 50, ringSpacing: 3)
        }
    }
    
    // NOTE: This does not seem to work in the interactive SwiftUI preview
    //       It does work in the simulator and on device
    struct AnimatedPreview: View {
        @State private var ring = Ring(
            completion: 0,
            startColor: CGColor(red:   0.0 / 255, green: 120.0 / 255, blue: 221.0 / 255, alpha: 1),
            endColor:   CGColor(red: 239.0 / 255, green: 072.0 / 255, blue: 120.0 / 255, alpha: 1)
        )
        
        private let animation = Animation
            .easeInOut(duration: 3)
            .repeatForever(autoreverses: true)
        
        var body: some View {
            CompletionRingView(ring: ring)
                .padding(20)
                .onAppear {
                    withAnimation(animation) {
                        ring.completion = 2.5
                    }
                }
        }
    }
    
    static var previews: some View {
        Group {
            // PreviewWithSlider()
            MultipleRingPreview()
            // AnimatedPreview()
        }
        .background(Color.black)
    }
}
