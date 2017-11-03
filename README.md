<img src="./Resources/lorikeet.svg" width="100%"/>

# Lorikeet

Lightweight framework for generating visually aesthetic color-schemes in Swift

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

let label = UILabel()
label.backgroundColor = red

// Assign a maximum contrasting color as foreground color
label.textColor = red.lkt.complimentaryColor

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

let range = HSVRange(hueRange: (0, 1),
         saturationRange: (0.5, 0.5),
         brightnessRange: (0.95, 0.95))

color.lkt.generateColorScheme(numberOfColors: 15,
                              withRange: range,
                              using: .cie2000) {
    colors in
}
```


### Screenshot

```swift
let color: UIColor = UIColor(red: 245/255.0, green: 110/255.0, blue: 100/255.0, alpha: 1)

color.lkt.generateColorScheme(numberOfColors: 10)
```

<img src="./Resources/generated_colors.png"/>
