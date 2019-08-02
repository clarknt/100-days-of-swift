//
//  ViewController.swift
//  Milestone-Projects28-30
//
//  Created by clarknt on 2019-07-23.
//  Copyright © 2019 clarknt. All rights reserved.
//

import UIKit

class ViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var cards = [Card]()
    var flippedCards = [(position: Int, card: Card)]()
    
    // too high values will trigger a fatal error due to spacing between cells becoming larger than screen
    // exemple on iPhone XS, limit is around 60x30 (values already unplayable anyway)
    let cardsLongNumber = 4
    let cardsShortNumber = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildCards()
    }

    func buildCards() {
        var backImage: String? = nil
        var frontImages = [String]()
        
        let urls = Bundle.main.urls(forResourcesWithExtension: nil, subdirectory: "Cards.bundle/Characters")!
        for url in urls {
            if url.lastPathComponent.starts(with: "back.") {
                backImage = url.path
            }
            else {
                frontImages.append(url.path)
            }
        }
        
        // no back card image found
        guard backImage != nil else { fatalError("No back image found") }

        let cardsNumber = cardsLongNumber * cardsShortNumber
        
        // more images than required grid
        while frontImages.count > cardsNumber / 2 {
            frontImages.remove(at: Int.random(in: 0..<frontImages.count))
        }
        // not enough images to fill grid
        while frontImages.count < cardsNumber / 2 {
            frontImages.append(frontImages[Int.random(in: 0..<frontImages.count)])
        }
        
        // duplicate all images to make pairs
        frontImages += frontImages
        // shuffle images
        frontImages.shuffle()
        
        for i in 0..<cardsNumber {
            cards.append(Card(frontImage: frontImages[i], backImage: backImage!))
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cards.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let dequeuedCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)

        guard let cell = dequeuedCell as? CardCell else { return dequeuedCell }

        let card = cards[indexPath.row]
        cell.set(frontImage: card.frontImage, backImage: card.backImage)

        return dequeuedCell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? CardCell else { return }

        guard flippedCards.count < 2 else { return }
        guard cards[indexPath.row].visibleSide == .back else { return }

        flippedCards.append((position: indexPath.row, card: cards[indexPath.row]))
        cards[indexPath.row].visibleSide = .front
        cell.flipTo(side: .front)

        if flippedCards.count == 2 {
            if flippedCards[0].card.frontImage == flippedCards[1].card.frontImage {
                matchedCards()
            }
            else {
                unmatchedCards()
            }
        }
    }
    
    func matchedCards() {
        for (position, _) in flippedCards {
            let indexPath = IndexPath(item: position, section: 0);
            if let cell = collectionView.cellForItem(at: indexPath) as? CardCell {
                // wait for flip animatiom to complete
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    cell.animateFound()
                }
            }
        }
        flippedCards.removeAll(keepingCapacity: true)
        
        checkCompletion()
    }
    
    func checkCompletion() {
        for card in cards {
            if card.visibleSide == .back {
                return
            }
        }
        
        // all cards complete
        animateCompletion()
    }
    
    func animateCompletion() {
        // work on background thread to allow sleeping
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) { [weak self] in
            guard self != nil else { return }
            
            for i in 0..<self!.cards.count {
                // 100ms sleep to start each animation with a delay
                usleep(100000)
                
                DispatchQueue.main.async {
                    let indexPath = IndexPath(item: i, section: 0);
                    if let cell = self!.collectionView.cellForItem(at: indexPath) as? CardCell {
                        cell.animateCompletion()
                    }
                }
            }
        }
    }
    
    func unmatchedCards() {
        // give the player 1 second to look at the cards
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard self != nil else { return }
            
            for (position, card) in self!.flippedCards {
                if card.visibleSide == .front {
                    card.visibleSide = .back
                    
                    let indexPath = IndexPath(item: position, section: 0);
                    if let cell = self?.collectionView.cellForItem(at: indexPath) as? CardCell {
                        cell.flipTo(side: .back)
                    }
                }
            }
            self!.flippedCards.removeAll(keepingCapacity: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return getCardSize(collectionView: collectionView)
    }
    
    func getCardSize(collectionView: UICollectionView) -> CGSize {
        let width = collectionView.frame.size.width
        let height = collectionView.frame.size.height
        
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        let minInterimSpacing = layout?.minimumInteritemSpacing ?? 0
        let minLineSpacing = layout?.minimumLineSpacing ?? 0
        
        let insets = collectionView.adjustedContentInset
        let leftRightInsets = insets.left + insets.right
        let topBottomInsets = insets.top + insets.bottom
        
        let layoutMargins = collectionView.layoutMargins
        let leftRightMargin = layoutMargins.left + layoutMargins.right
        let topBottomMargin = CGFloat(0) // no need for layoutMargins.top + layoutMargins.bottom

        var widthCardNumber: CGFloat
        var heightCardNumber: CGFloat
        
        // portrait
        if height > width {
            widthCardNumber = CGFloat(cardsShortNumber)
            heightCardNumber = CGFloat(cardsLongNumber)
        }
        // landscape
        else {
            widthCardNumber = CGFloat(cardsLongNumber)
            heightCardNumber = CGFloat(cardsShortNumber)
        }
        
        let availableWidth = width - leftRightMargin - leftRightInsets - minInterimSpacing * widthCardNumber
        let availableHeight = height - topBottomMargin - topBottomInsets - minLineSpacing * heightCardNumber
        
        guard availableWidth > widthCardNumber && availableHeight > heightCardNumber else {
            fatalError("Too many cards to display")
        }
        
        let cardWidth = availableWidth / widthCardNumber
        let cardHeight = availableHeight / heightCardNumber

        return CGSize(width: cardWidth, height: cardHeight)
    }
}
