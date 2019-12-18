//
//  ViewController.swift
//  Milestone-Projects28-30
//
//  Created by clarknt on 2019-07-23.
//  Copyright © 2019 clarknt. All rights reserved.
//

import UIKit

class GameViewController: UICollectionViewController {

    // MARK:- Properties

    var cards = [Card]()
    var flippedCards = [(position: Int, card: Card)]()

    var backImageSize: CGSize!
    var cardSize: CardSize!
    
    var currentGrid = 4
    var currentGridElement = 1
    
    let cardsDirectory = "Cards.bundle/"
    var currentCards = "Characters"

    var currentCardSizeValid = false
    var currentCardSize: CGSize!
    
    var previousWindowBounds: CGRect?
    
    var flipAnimator = FlipCardAnimator()
    var matchedCardsAnimators = [MatchedCardsAnimator]()
    var unmatchedCardsAnimator = UnmatchedCardsAnimator()
    var completionAnimator = CompletionAnimator()



    // MARK:- Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Match Pairs"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "New game", style: .plain, target: self, action: #selector(newGame))

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(settingsTapped))

        let (gridSide1, gridSide2) = grids[currentGrid].combinations[currentGridElement]
        // loading default values, they will be overriden later
        cardSize = CardSize(imageSize: CGSize(width: 50, height: 50), gridSide1: gridSide1, gridSide2: gridSide2)
        
        newGame()
    }
    
    // monitor actual window size change, occuring when rotating device
    // but also when using split view on ipad
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // avoid an infinite loop by making sure there was an actual change in size
        if let currentBounds = view.window?.bounds {
            if let previousBounds = previousWindowBounds {
                if currentBounds != previousBounds {
                    currentCardSizeValid = false
                    collectionView?.collectionViewLayout.invalidateLayout()
                }
            }
        }
        
        previousWindowBounds = view.window?.bounds
    }

    @objc func newGame() {
        let (gridSide1, gridSide2) = grids[currentGrid].combinations[currentGridElement]

        guard (gridSide1 * gridSide2) % 2 == 0 else {
            fatalError("Odd number of cards")
        }
        
        cardSize.gridSide1 = gridSide1
        cardSize.gridSide2 = gridSide2

        cards = [Card]()
        resetFlippedCards()
        cancelAnimators()
        
        loadCards()

        currentCardSizeValid = false
        collectionView.reloadData()
    }
    
    func resetFlippedCards() {
        flippedCards.removeAll(keepingCapacity: true)
    }

    func cancelAnimators() {
        flipAnimator.cancel()
        unmatchedCardsAnimator.cancel()
        for animator in matchedCardsAnimators {
            animator.cancel()
        }
        matchedCardsAnimators.removeAll()
        completionAnimator.cancel()
    }

    @objc func settingsTapped() {
        if let settings = storyboard?.instantiateViewController(withIdentifier: "SettingsViewController") as? SettingsViewController {
            settings.setParameters(currentCards: currentCards, currentGrid: currentGrid, currentGridElement: currentGridElement)
            settings.delegate = self
            navigationController?.pushViewController(settings, animated: true)
        }
    }
    
    func loadCards() {
        var backImage: String? = nil
        var frontImages = [String]()

        let urls = Bundle.main.urls(forResourcesWithExtension: nil, subdirectory: cardsDirectory + currentCards)!
        
        for url in urls {
            // convention: unique names to avoid caching issue
            // and starting with 1 for sorting
            if url.lastPathComponent.starts(with: "1\(currentCards)_back.") {
                backImage = url.path
            }
            else {
                frontImages.append(url.path)
            }
        }
        
        // get image size
        guard backImage != nil else { fatalError("No back image found") }
        guard let size = UIImage(named: backImage!)?.size else { fatalError("Cannot get image size") }
        cardSize.imageSize = size

        let (gridSide1, gridSide2) = grids[currentGrid].combinations[currentGridElement]
        let cardsNumber = gridSide1 * gridSide2
        
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
    
    func matchCards() {
        guard let (oldCard, oldCell) = getFlippedCard(at: 0) else { return }
        guard let (newCard, newCell) = getFlippedCard(at: 1) else { return }

        oldCard.state = .matched
        newCard.state = .matched

        let animator = MatchedCardsAnimator()
        matchedCardsAnimators.append(animator)

        animator.start(oldCell: oldCell, newCell: newCell) { [weak self] in
            self?.matchedCardsAnimators.removeAll(where: { $0 === animator })
            self?.checkCompletion()
        }

        flippedCards.removeAll(keepingCapacity: true)
    }
    
    func checkCompletion() {
        guard matchedCardsAnimators.isEmpty else { return }

        for card in cards {
            if card.state != .matched && card.state != .complete {
                return
            }
        }
        
        // all cards complete
        for card in cards {
            card.state = .complete
        }

        completionAnimator.start(cards: cards, collectionView: collectionView)
    }

    func unmatchCards() {
        guard let (oldCard, oldCell) = getFlippedCard(at: 0) else { return }
        guard let (newCard, newCell) = getFlippedCard(at: 1) else { return }

        oldCard.state = .back
        newCard.state = .back

        unmatchedCardsAnimator.start(oldCell: oldCell, newCell: newCell) { [weak self] in
            self?.resetFlippedCards()
        }
    }

    func forceFinishUnmatchCards() {
        guard let (_, oldCell) = getFlippedCard(at: 0) else { return }
        guard let (_, newCell) = getFlippedCard(at: 1) else { return }

        // won't have any effect if no unmatching is currently going on
        unmatchedCardsAnimator.forceFlipToBack(oldCell: oldCell, newCell: newCell)

        resetFlippedCards()
    }

    func getFlippedCard(at index: Int) -> (Card, CardCell)? {
        let (position, card) = flippedCards[index]

        let indexPath = IndexPath(item: position, section: 0)

        guard let cell = collectionView.cellForItem(at: indexPath) as? CardCell else {
            print("Get card error")
            return nil
        }

        return (card, cell)
    }
}



// MARK:- SettingsDelegate

extension GameViewController: SettingsDelegate {

    func settings(_ settings: SettingsViewController, didUpdateCards cards: String) {
        currentCards = cards
        newGame()
    }

    func settings(_ settings: SettingsViewController, didUpdateGrid grid: Int, didUpdateGridElement gridElement: Int) {
        currentGrid = grid
        currentGridElement = gridElement
        newGame()
    }
}




// MARK:- UICollectionViewDataSource

extension GameViewController {

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cards.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let dequeuedCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)

        guard let cell = dequeuedCell as? CardCell else { return dequeuedCell }

        cell.set(card: cards[indexPath.row])

        return cell
    }
}



// MARK:- UICollectionViewDelegate

extension GameViewController {

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? CardCell else { return }

        guard cards[indexPath.row].state == .back else { return }

        cards[indexPath.row].state = .front

        if flippedCards.count == 0 {
            flipAnimator.flipTo(state: .front, cell: cell)
            flippedCards.append((position: indexPath.row, card: cards[indexPath.row]))
            return
        }

        if flippedCards.count == 1 {
            flippedCards.append((position: indexPath.row, card: cards[indexPath.row]))

            if flippedCards[0].card.frontImage == flippedCards[1].card.frontImage {
                matchCards()
            }
            else {
                unmatchCards()
            }
            return
        }

        if flippedCards.count == 2 {
            // one of the two front facing cards
            if indexPath.row == flippedCards[0].position || indexPath.row == flippedCards[1].position {
                cards[indexPath.row].state = .back
                forceFinishUnmatchCards()
                return
            }
            // another card
            forceFinishUnmatchCards()
            flipAnimator.flipTo(state: .front, cell: cell)
            flippedCards.append((position: indexPath.row, card: cards[indexPath.row]))
            return
        }
    }
}



// MARK:- UICollectionViewDelegateFlowLayout

extension GameViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if currentCardSizeValid {
            return currentCardSize
        }

        currentCardSize = cardSize.getCardSize(collectionView: collectionView)
        currentCardSizeValid = true
        return currentCardSize
    }
}
