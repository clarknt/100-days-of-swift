//
//  ViewController.swift
//  Milestone-Projects25-27
//

import UIKit

enum Position {
    case top
    case bottom
}

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var topCaptionButton: UIButton!
    @IBOutlet var bottomCaptionButton: UIButton!
    
    var topCaption: String?
    var bottomCaption: String?
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(exportAction))
        
        updateButtonsState(enable: false)

        // queue the drawing otherwise imageView size is not defined yet
        DispatchQueue.main.async { [weak self] in
            self?.setDefaultImage()
        }
    }

    func setDefaultImage() {
        let size = imageView.frame.size

        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { ctx in
            let defaultText = "Import an image to start"
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attrs: [NSAttributedString.Key : Any] = [
                .foregroundColor: UIColor.lightGray,
                .font: UIFont(name: "HelveticaNeue", size: 18)!,
                .paragraphStyle: paragraphStyle
            ]
	
            let margin = 32
            let textWidth = Int(size.width) - (margin * 2)
            let textHeight = computeTextHeight(for: defaultText, attributes: attrs, width: Int(textWidth))
            let textStartY = (Int(size.height) - textHeight) / 2
            defaultText.draw(with: CGRect(x: margin, y: textStartY, width: textWidth, height: textHeight), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
        }
        
        imageView.image = image
    }
    
    func updateButtonsState(enable: Bool) {
        topCaptionButton.isEnabled = enable
        bottomCaptionButton.isEnabled = enable
        navigationItem.rightBarButtonItem?.isEnabled = enable
    }
    
    @objc func exportAction() {
        guard let image = imageView.image?.jpegData(compressionQuality: 0.8) else { return }
        
        let vc = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }

    @IBAction func importAction(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        
        dismiss(animated: true)
        
        imageView.image = image

        self.image = image
        topCaption = nil
        bottomCaption = nil
        
        updateButtonsState(enable: true)
    }
    
    @IBAction func topCaptionAction(_ sender: Any) {
        showCaptionAlert(for: .top)
    }
    
    @IBAction func bottomCaptionAction(_ sender: Any) {
        showCaptionAlert(for: .bottom)
    }
    
    func showCaptionAlert(for position: Position) {
        var title = ""
        if position == .top { title = "Top caption" }
        else if position == .bottom { title = "Bottom caption" }

        let ac = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self, weak ac] action in
            guard let text = ac?.textFields?[0].text else { return }
            
            if position == .top { self?.topCaption = text }
            else if position == .bottom { self?.bottomCaption = text }
            
            self?.addCaptions()
        }))
        
        present(ac, animated: true)
    }
    
    func addCaptions() {
        guard let image = image else { return }
        
        let renderer = UIGraphicsImageRenderer(size: image.size)
        
        let renderedImage = renderer.image { [weak self] ctx in
            image.draw(at: CGPoint(x: 0, y: 0))
            
            if let topCaption = self?.topCaption {
                drawText(text: topCaption, position: .top, rendererSize: image.size)
            }
            
            if let bottomCaption = self?.bottomCaption {
                drawText(text: bottomCaption, position: .bottom, rendererSize: image.size)
            }
        }

        imageView.image = renderedImage
    }
    
    func drawText(text: String, position: Position, rendererSize: CGSize) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        // accomodate all images sizes
        let sidesLength = rendererSize.width + rendererSize.height
        let fontSize = sidesLength / 30
        
        let attrs: [NSAttributedString.Key : Any] = [
            .strokeWidth: -2.0,
            .strokeColor: UIColor.black,
            .foregroundColor: UIColor.white,
            .font: UIFont(name: "HelveticaNeue", size: fontSize)!,
            .paragraphStyle: paragraphStyle
        ]
        
        let margin = 32
        let textWidth = Int(rendererSize.width) - (margin * 2)
        let textHeight = computeTextHeight(for: text, attributes: attrs, width: textWidth)
        
        var startY: Int
        switch position {
        case .top:
            startY = margin
        case .bottom:
            startY = Int(rendererSize.height) - (textHeight + margin)
        }
        
        text.draw(with: CGRect(x: margin, y: startY, width: textWidth, height: textHeight), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
    }
    
    func computeTextHeight(for text: String, attributes: [NSAttributedString.Key : Any], width: Int) -> Int {
        let nsText = NSString(string: text)
        let size = CGSize(width: CGFloat(width), height: .greatestFiniteMagnitude)
        let textRect = nsText.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)

        return Int(ceil(textRect.size.height))
    }
}

