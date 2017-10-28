<img src="./Resources/lorikeet.svg" width="100%"/>

# Lorikeet

Lightweight framework for generating complimentary color-schemes in Swift

## Features
What can Lorikeet do for you

- Calculate visual color difference
    - Algorithms:
        - CIE76
        - CIE94
        - CIE2000
- Generate color schemes

## Installation

### Carthage
In your `Cartfile` put:

```
github "valdirunars/Lorikeet"
```

### Manual
Copy the `./Lorikeet` folder 😁🗂

## How to Use

### Basic Usage

```swift
let red: UIColor = .red

// Visual color difference
let distance: Float = red.distance(to: .blue, algorithm: .cie2000)

// Generate color scheme
red.lkt.generateColorScheme(numberOfColors: 40) { colors in
    print(colors)
}
```

### Advanced

Lorikeet's `Algorithm` enum has two cases for advanced usage:
    - `.advancedCIE94(l: Float, c: Float, h: Float, k1: Float, k2: Float)`
    - `.advancedCIE2000(l: Float, c: Float, h: Float)`

Example:
```swift
let l: Float = 0.8
let c: Float = 0.9
let h: Float = 1.0

red.lkt.generateColorScheme(numberOfColors: 40,
                            using: .advancedCIE2000(l: l, c: c, h: h)) { colors in
    print(colors)
}
```
