<img src="./Resources/lorikeet.svg" width="100%"/>

# Lorikeet

Lightweight framework for generating complimentary color-schemes in Swift

## Requirements

- Swift 3
- UIKit

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
```swift
.advancedCIE94(l: Float, c: Float, h: Float, k1: Float, k2: Float)
```

```swift
.advancedCIE2000(l: Float, c: Float, h: Float)
```
Example:
```swift
let l: Float = 0.8
let c: Float = 0.9
let h: Float = 1.0

red.lkt.generateColorScheme(numberOfColors: 40,
                            using: .advancedCIE2000(l: l, c: c, h: h)) { colors in
    print(colors)
}

// It's also possible to specify the color type
// and brightness
// Current possible types are .pastel and .flat
// and .custom(saturation: Float, brightnessFactor: Float)
// By default the type is .flat with a
// brightnessFactor of 1.0
red.lkt.generateColorScheme(numberOfColors: 5, colorType: .pastel(brightnessFactor: 0.85), using: .cie94) {
    print($0)
}

```


### Screenshot

```swift
let color: UIColor = UIColor.init(red: 245/255.0, green: 110/255.0, blue: 100/255.0, alpha: 1)

color.lkt.generateColorScheme(numberOfColors: 10, colorType: .flat(brightnessFactor: 0.95))
```

<img src="./Resources/generated_colors.png"/>
