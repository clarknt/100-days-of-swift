# Core Graphics redux

https://www.hackingwithswift.com/100/91

The "Learn Core Graphics" playground (see link above) contains challenges to be solved directly within the playground. Solutions to these challenges are below.

## Challenges

Quotes are from the [Hacking with Swift Core Graphics Playground](https://www.hackingwithswift.com/playgrounds).

### Drawing shapes

#### Rectangles

>Can you write some code to draw a red box on top of the blue one, making it 200x200 and centered like the blue one?

```swift
UIColor.red.setFill()
ctx.cgContext.fill(CGRect(x: 400, y: 400, width: 200, height: 200))
```
#### Stripes

>Can you draw the five rectangles in their correct colors? The first one has been done for you.

```swift
let colors: [UIColor] = [.orange, .yellow, .green, .blue]
for (i, color) in colors.enumerated() {
    color.setFill()
    ctx.cgContext.fill(CGRect(x: (i + 1) * 200, y: 0, width: 200, height: 1000))
}
```

#### Flags

>Recreate your designer's image, but this time using a yellow background and an orange cross. Your designer suggested a couple of lines for you, which should give you a headstart.

```swift
UIColor.yellow.setFill()
ctx.cgContext.fill(CGRect(x: 0, y: 0, width: 1000, height: 1000))

UIColor.orange.setFill()
ctx.cgContext.fill(CGRect(x: 0, y: 400, width: 1000, height: 200))
ctx.cgContext.fill(CGRect(x: 400, y: 0, width: 200, height: 1000))
```

#### Checkerboards

>The code below makes a checkerboard, but it doesn't fill the image correctly. Try adjusting the grid size, number of rows, and number of columns so that you get a 10x10 checkerboard across the entire image.

```swift
UIColor.black.setFill()

let size = 100

for row in 0 ..< 10 {
    for col in 0 ..< 10 {
        if (row + col) % 2 == 0 {
            ctx.cgContext.fill(CGRect(x: col * size, y: row * size, width: size, height: size))
        }
    }
}
```

#### Ellipses

>The code below draws one red circle in the top-left corner, but your designer wants you to create three more: a yellow circle in the top-right corner, a blue circle in the bottom-left corner, and a green circle in the bottom-right corner.

```Swift
UIColor.yellow.setFill()
let circle2 = CGRect(x: 500, y: 0, width: 500, height: 500)
ctx.cgContext.fillEllipse(in: circle2)

UIColor.blue.setFill()
let circle3 = CGRect(x: 0, y: 500, width: 500, height: 500)
ctx.cgContext.fillEllipse(in: circle3)

UIColor.green.setFill()
let circle4 = CGRect(x: 500, y: 500, width: 500, height: 500)
ctx.cgContext.fillEllipse(in: circle4)
```

#### Flowers

>Your designer has provided a sketch of what they want: four red circles, with a black circle in the middle. Can you make this happen using ellipses? They've drawn the first one for you, but it isn't quite right.

```swift
UIColor.red.setFill()
let circle1 = CGRect(x: 100, y: 100, width: 500, height: 500)
ctx.cgContext.fillEllipse(in: circle1)

let circle2 = CGRect(x: 400, y: 100, width: 500, height: 500)
ctx.cgContext.fillEllipse(in: circle2)

let circle3 = CGRect(x: 100, y: 400, width: 500, height: 500)
ctx.cgContext.fillEllipse(in: circle3)

let circle4 = CGRect(x: 400, y: 400, width: 500, height: 500)
ctx.cgContext.fillEllipse(in: circle4)

UIColor.black.setFill()
let center = CGRect(x: 400, y: 400, width: 200, height: 200)
ctx.cgContext.fillEllipse(in: center)
```

#### Strokes

>Can you recreate their logo sketch using ellipses, strokes, and fills? They already added the first circle for you, which should give you a nice template for the others.

```swift
ctx.cgContext.setLineWidth(10)

let topCircle = CGRect(x: 400, y: 100, width: 200, height: 200)
ctx.cgContext.addEllipse(in: topCircle)
ctx.cgContext.drawPath(using: .fillStroke)

let leftCircle = CGRect(x: 100, y: 400, width: 200, height: 200)
ctx.cgContext.addEllipse(in: leftCircle)
ctx.cgContext.drawPath(using: .fillStroke)

let bottomCircle = CGRect(x: 400, y: 700, width: 200, height: 200)
ctx.cgContext.addEllipse(in: bottomCircle)
ctx.cgContext.drawPath(using: .fillStroke)

let rightCircle = CGRect(x: 700, y: 400, width: 200, height: 200)
ctx.cgContext.addEllipse(in: rightCircle)
ctx.cgContext.drawPath(using: .fillStroke)
```

#### Rainbows

>Your designer has produced a sketch showing how it should look. Can you adjust the code to help make it work correctly?

```swift
xPos += 50
yPos += 50
size -= 100

let rect = CGRect(x: xPos, y: yPos, width: size, height: size)
color.setStroke()
ctx.cgContext.strokeEllipse(in: rect)
```
#### Emoji

>Try to recreate your designer's sketch using four circles. The face should be colored yellow, the mouth brown, and both eyes black. Your designer has helped write the code for the face, but it isn't quite right.

```swift
UIColor.black.setStroke()
UIColor.yellow.setFill()
ctx.cgContext.setLineWidth(10)

let face = CGRect(x: 100, y: 100, width: 800, height: 800)
ctx.cgContext.addEllipse(in: face)
ctx.cgContext.drawPath(using: .fillStroke)

UIColor.black.setFill()
let leftEye = CGRect(x: 250, y: 300, width: 150, height: 150)
ctx.cgContext.addEllipse(in: leftEye)
ctx.cgContext.drawPath(using: .fillStroke)

let rightEye = CGRect(x: 600, y: 300, width: 150, height: 150)
ctx.cgContext.addEllipse(in: rightEye)
ctx.cgContext.drawPath(using: .fillStroke)

UIColor.brown.setFill()
let mouth = CGRect(x: 350, y: 500, width: 300, height: 300)
ctx.cgContext.addEllipse(in: mouth)
ctx.cgContext.drawPath(using: .fillStroke)
```

### Advanced drawing

#### Text

>Someone has been putting up inspirational posters around your office, saying "The early bird catches the worm." Your designer wants your help to design a modified version that says "But the second mouse gets the cheese" in red text 100 pixels below. Can you write code to match their sketch?

```swift
let secondPosition = rect.offsetBy(dx: 0, dy: 400)
let secondText = "But the second mouse gets the cheese."
let secondAttrs: [NSAttributedString.Key: Any] = [
    .font: UIFont.systemFont(ofSize: 72),
    .foregroundColor: UIColor.red
]

let secondString = NSAttributedString(string: secondText, attributes: secondAttrs)
secondString.draw(in: secondPosition)
```

#### Lines

>Your team tried to write code to draw the flag, but only managed one arm of the cross and even then it's far too small – it needs to stretch from corner to corner, and have another arm going in the other direction. Your designer also thinks a 10-pixel width is too small, and suggests trying 100 instead. Can you use Core Graphics to draw a good-looking Scottish flag like the one below?

```swift
UIColor(red: 0, green: 0.37, blue: 0.72, alpha: 1).setFill()
ctx.cgContext.fill(rect)
UIColor.white.setStroke()

ctx.cgContext.setLineWidth(100)

ctx.cgContext.move(to: CGPoint(x: 0, y: 0))
ctx.cgContext.addLine(to: CGPoint(x: 1000, y: 1000))

ctx.cgContext.move(to: CGPoint(x: 1000, y: 0))
ctx.cgContext.addLine(to: CGPoint(x: 0, y: 1000))

ctx.cgContext.strokePath()
```

#### Images

>Your designer wants you to create a picture frame effect for an image. He's placed the frame at the right size, but it's down to you to position it correctly then position and size the image inside it.

```swift
UIColor.darkGray.setFill()
ctx.cgContext.fill(rect)

UIColor.black.setFill()
let borderRect = CGRect(x: 180, y: 180, width: 640, height: 640)
ctx.cgContext.fill(borderRect)

let imageRect = CGRect(x: 300, y: 300, width: 400, height: 400)
mascot?.draw(in: imageRect)
```

#### Translation

>One of your teammates has tried to reproduce a design that places circles across the screen, but they aren't having much luck. Can you adjust their code so that the seven circles are positioned and sized correctly?

```swift
let ellipseRectangle = CGRect(x: 0, y: 300, width: 400, height: 400)
ctx.cgContext.setLineWidth(8)
UIColor.red.setStroke()

for _ in 1...7 {
    ctx.cgContext.strokeEllipse(in: ellipseRectangle)
    ctx.cgContext.translateBy(x: 100, y: 0)
}
```

#### Rotation

>Can you fix this code so that it draws the designer's sketch as they want? You might want to start by adjusting the translateBy() call.

```swift
ctx.cgContext.setLineWidth(8)
ctx.cgContext.translateBy(x: 500, y: 500)

for _ in 1...8 {
    ctx.cgContext.addRect(boxRectangle)
    ctx.cgContext.rotate(by: .pi / 4)
}

UIColor.red.setStroke()
ctx.cgContext.strokePath()
```

#### Blending

>Try some alternative blend modes to see what you can come up with – it's common to use .multiply to make one color to darken another, for example.

```swift
let blendMode = CGBlendMode.xor
//let blendMode = CGBlendMode.difference
ctx.cgContext.setBlendMode(blendMode)

UIColor.red.setFill()
ctx.cgContext.fillEllipse(in: CGRect(x: 200, y: 200, width: 400, height: 400))
ctx.cgContext.fillEllipse(in: CGRect(x: 400, y: 200, width: 400, height: 400))
ctx.cgContext.fillEllipse(in: CGRect(x: 400, y: 400, width: 400, height: 400))
ctx.cgContext.fillEllipse(in: CGRect(x: 200, y: 400, width: 400, height: 400))
```
