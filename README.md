# CompletionRingsView

A pure SwiftUI View that renders one or more circular completion indicators, which can go past 100%

<img src="https://user-images.githubusercontent.com/6288076/162584258-bb0c3969-449f-4d77-96ff-2f6b8843b3c8.png" align="center" alt="Example screenshot" />

### Demo Video
https://user-images.githubusercontent.com/6288076/162584090-ad4469a3-74b7-468d-8637-2fec1ee64b86.mov


## Example Usage

```swift
// Renders a single static ring
struct SingleRingPreview: View {
    let ring = Ring(
        completion: 0.5,
        startColor: UIColor.blue.cgColor
        endColor:   UIColor.red.cgColor
    )
    
    var body: some View {
        CompletionRingView(ring: ring)
            .padding(20)
    }
}

// Renders a single ring, which animates from 0% to 250% and back again
struct AnimatedSingleRingPreview: View {
    @State private var ring = Ring(
        completion: 0,
        startColor: UIColor.blue.cgColor
        endColor:   UIColor.red.cgColor
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

// Renders multiple rings and animates them
struct AnimatedMultipleRingPreview: View {
    @State private var rings: [Ring] = [
        Ring(
            completion: 0,
            startColor: UIColor.blue.cgColor
            endColor:   UIColor.red.cgColor
        ),
        Ring(
            completion: 0,
            startColor: UIColor.red.cgColor
            endColor:   UIColor.yellow.cgColor
        ),
        Ring(
            completion: 0,
            startColor: UIColor.yellow.cgColor
            endColor:   UIColor.green.cgColor
        ),
    ]
    
    private let animation = Animation
        .easeInOut(duration: 3)
        .repeatForever(autoreverses: true)
    
    var body: some View {
        CompletionRingsView(rings: rings)
            .padding(20)
            .onAppear {
                withAnimation(animation) {
                    rings[0].completion = 0.75
                    rings[1].completion = 1.25
                    rings[2].completion = 1.75
                }
            }
    }
}
```
