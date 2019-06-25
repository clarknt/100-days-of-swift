//
//  ViewController.swift
//  Project27
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    
    var currentDrawType = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        drawRectangle()
    }

    @IBAction func redrawTapped(_ sender: Any) {
        currentDrawType += 1
        
        // challenge 1
        if currentDrawType > 7 {
            currentDrawType = 0
        }
        
        switch currentDrawType {
        case 0:
            drawRectangle()
        case 1:
            drawCircle()
        case 2:
            drawCheckerboard()
        case 3:
            drawRotatedSquares()
        case 4:
            drawLines()
        case 5:
            drawImagesAndText()
        case 6:
            // challenge 1
            drawSurprisedEmoji()
        case 7:
            // challenge 1
            drawStarEmoji()
        default:
            break
        }
    }
    
    func drawRectangle() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let image = renderer.image { ctx in
            let rectangle = CGRect(x: 0, y: 0, width: 512, height: 512)
            
            ctx.cgContext.setFillColor(UIColor.red.cgColor)
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(10)
            
            ctx.cgContext.addRect(rectangle)
            ctx.cgContext.drawPath(using: .fillStroke)
        }
        
        imageView.image = image
    }
    
    func drawCircle() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let image = renderer.image { ctx in
            let rectangle = CGRect(x: 0, y: 0, width: 512, height: 512).insetBy(dx: 5, dy: 5)
            
            ctx.cgContext.setFillColor(UIColor.red.cgColor)
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(10)
            
            ctx.cgContext.addEllipse(in: rectangle)
            ctx.cgContext.drawPath(using: .fillStroke)
        }
        
        imageView.image = image
    }
    
    func drawCheckerboard() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let image = renderer.image { ctx in
            ctx.cgContext.setFillColor(UIColor.black.cgColor)
            
            for row in 0..<8 {
                for col in 0..<8 {
                    if (row + col).isMultiple(of: 2) {
                        // no need to add a path with fill
                        ctx.cgContext.fill(CGRect(x: col * 64, y: row * 64, width: 64, height: 64))
                    }
                }
            }
        }
        
        imageView.image = image
    }
    
    func drawRotatedSquares() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let image = renderer.image { ctx in
            // contrary to UIView which rotates around the center,
            // Core Graphics rotate around the top left corner
            ctx.cgContext.translateBy(x: 256, y: 256)
            
            let rotations = 16
            let amount = Double.pi / Double(rotations)
            
            for _ in 0..<rotations {
                ctx.cgContext.rotate(by: CGFloat(amount))
                ctx.cgContext.addRect(CGRect(x: -128, y: -128, width: 256, height: 256))
            }
            
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.strokePath()
        }
        
        imageView.image = image
    }

    func drawLines() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let image = renderer.image { ctx in
            ctx.cgContext.translateBy(x: 256, y: 256)
            
            var first = true
            var length: CGFloat = 256
            
            for _ in 0..<256 {
                ctx.cgContext.rotate(by: .pi / 2)
            
                if first {
                    ctx.cgContext.move(to: CGPoint(x: length, y: 50))
                    first = false
                }
                else {
                    ctx.cgContext.addLine(to: CGPoint(x: length, y: 50))
                }
                
                length *= 0.99
            }
            
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.strokePath()
        }
        
        imageView.image = image
    }

    func drawImagesAndText() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let image = renderer.image { ctx in
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 36),
                .paragraphStyle: paragraphStyle
            ]

            let string = "The best-laid schemes o'\nmice an' men gang aft agley"
            
            let attributedString = NSAttributedString(string: string, attributes: attrs)
            attributedString.draw(with: CGRect(x: 32, y: 32, width: 448, height: 448), options: .usesLineFragmentOrigin, context: nil)
            
            let mouse = UIImage(named: "mouse")
            mouse?.draw(at: CGPoint(x: 300, y: 150))
        }
        
        imageView.image = image
    }
   
    // challenge 1
    func drawSurprisedEmoji() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let image = renderer.image { ctx in
            let face = CGRect(x: 0, y: 0, width: 512, height: 512).insetBy(dx: 20, dy: 20)
            
            ctx.cgContext.setFillColor(UIColor.yellow.cgColor)
            ctx.cgContext.setStrokeColor(UIColor.orange.cgColor)
            ctx.cgContext.setLineWidth(5)
            
            ctx.cgContext.addEllipse(in: face)
            ctx.cgContext.drawPath(using: .fillStroke)
            
            let eye = CGRect(x: 0, y: 0, width: 60, height: 70)
            ctx.cgContext.setFillColor(UIColor.orange.cgColor)

            ctx.cgContext.translateBy(x: 130, y: 150)
            ctx.cgContext.addEllipse(in: eye)
            ctx.cgContext.drawPath(using: .fill)
            
            ctx.cgContext.translateBy(x: 190, y: 0)
            ctx.cgContext.addEllipse(in: eye)
            ctx.cgContext.drawPath(using: .fill)

            let mouth = CGRect(x: 0, y: 0, width: 100, height: 110)

            ctx.cgContext.translateBy(x: -110, y: 150)
            ctx.cgContext.addEllipse(in: mouth)
            ctx.cgContext.drawPath(using: .fill)
        }
        
        imageView.image = image
    }
    
    // challenge 1
    func drawStarEmoji() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let image = renderer.image { ctx in
            ctx.cgContext.translateBy(x: 256, y: 270)
            
            let innerRadius: CGFloat = 94
            let outerRadius: CGFloat = 245
            let starPoints = 5
            
            let initialInnerPoint = pointOnCircle(radius: innerRadius, angle: 0)
            ctx.cgContext.move(to: initialInnerPoint)

            for _ in 1...starPoints {
                let starPoints = CGFloat(starPoints)

                let outerPoint = pointOnCircle(radius: outerRadius, angle: .pi * 2 / (starPoints * 2))
                ctx.cgContext.addLine(to: outerPoint)
                
                let innerPoint = pointOnCircle(radius: innerRadius, angle: .pi * 2 / starPoints)
                ctx.cgContext.addLine(to: innerPoint)

                ctx.cgContext.rotate(by: -(.pi * 2 / starPoints))
            }
            
            ctx.cgContext.closePath()

            ctx.cgContext.setStrokeColor(UIColor.orange.cgColor)
            ctx.cgContext.setLineWidth(10)

            ctx.cgContext.setFillColor(UIColor.yellow.cgColor)

            ctx.cgContext.drawPath(using: .fillStroke)
        }
        
        imageView.image = image
    }
    
    // challenge 1
    func pointOnCircle(radius: CGFloat, angle: CGFloat) -> CGPoint {
        return CGPoint(x: radius * sin(angle), y: radius * cos(angle))
    }
}

