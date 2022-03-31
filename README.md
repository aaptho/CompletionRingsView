# CompletionRingsView

A pure SwiftUI View that renders one or more circular completion indicators, which can go past 100%

## Example Usage

```
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
