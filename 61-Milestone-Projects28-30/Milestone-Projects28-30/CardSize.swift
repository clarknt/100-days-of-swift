//
//  CardSize.swift
//  Milestone-Projects28-30
//
//  Created by clarknt on 2019-08-04.
//  Copyright © 2019 clarknt. All rights reserved.
//

import UIKit

class CardSize {
    var imageSize: CGSize
    var gridSide1: Int
    var gridSide2: Int
    
    init(imageSize: CGSize, gridSide1: Int, gridSide2: Int) {
        self.imageSize = imageSize
        self.gridSide1 = gridSide1
        self.gridSide2 = gridSide2
    }
    
    func getCardSize(collectionView: UICollectionView) -> CGSize {
        let width = collectionView.frame.size.width
        let height = collectionView.frame.size.height
        
        let layoutMargins = collectionView.layoutMargins
        let leftRightMargin = layoutMargins.left + layoutMargins.right
        let topBottomMargin = layoutMargins.top + layoutMargins.bottom
        
        // ignore section insets and spacing between cards, they will be computed later
        var availableWidth = width - leftRightMargin
        var availableHeight = height - topBottomMargin
        
        // optimize cards layout to make best use of the available space
        let (widthCardNumber, heightCardNumber) = getWidthHeightCardNumber(availableWidth: availableWidth, availableHeight: availableHeight)
        
        // card size with no section insets and spacing between cards
        var cardWidth = availableWidth / widthCardNumber
        var cardHeight = availableHeight / heightCardNumber
        
        // size of spacing between cards, and minimum size of section insets
        let widthSpacing = floor(min(cardWidth, cardHeight) / 10)
        let heightSpacing = widthSpacing
        
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        
        // update spacing between cards
        layout?.minimumInteritemSpacing = heightSpacing
        layout?.minimumLineSpacing = widthSpacing
        
        // add spacing between cards and a minimum section inset
        availableWidth -= widthSpacing * (widthCardNumber + 1)
        availableHeight -= heightSpacing * (heightCardNumber + 1)
        
        // card size with spacing between cards and minimum section inset
        cardWidth = availableWidth / widthCardNumber
        cardHeight = availableHeight / heightCardNumber
        
        // difference between computed size and actual image size
        let widthDifference = cardWidth - (cardHeight * imageSize.width / imageSize.height)
        let heightDifference = cardHeight - (cardWidth * imageSize.height / imageSize.width)
        
        // compute section insets to push cards towards the center while having an even spacing
        if widthDifference > heightDifference {
            let totalDifference = widthDifference * widthCardNumber
            let leftRightSectionInset = floor(widthSpacing + (totalDifference / 2))
            let topBottomSectionInset = heightSpacing
            
            // update section insets
            layout?.sectionInset = UIEdgeInsets(top: topBottomSectionInset, left: leftRightSectionInset, bottom: topBottomSectionInset, right: leftRightSectionInset)
            
            // update available width with new insets
            availableWidth -= totalDifference
        }
        else if heightDifference > widthDifference {
            let totalDifference = heightDifference * heightCardNumber
            let topBottomSectionInset = floor(heightSpacing + (totalDifference / 2))
            let leftRightSectionInset = widthSpacing
            
            // update section insets
            layout?.sectionInset = UIEdgeInsets(top: topBottomSectionInset, left: leftRightSectionInset, bottom: topBottomSectionInset, right: leftRightSectionInset)
            
            // update available height with new insets
            availableHeight -= totalDifference
        }
        
        // rounding will cause issues with total size
        // to overcome this, floor each card, then add the remainder to the section insets
        cardWidth = floor(availableWidth / widthCardNumber)
        cardHeight = floor(availableHeight / heightCardNumber)
        
        let widthRemainder = floor((availableWidth - (cardWidth * widthCardNumber)) / 2)
        let heightRemainder = floor((availableHeight - (cardHeight * heightCardNumber)) / 2)
        
        if let layout = layout {
            let left = layout.sectionInset.left + widthRemainder
            let right = layout.sectionInset.right + widthRemainder
            let top = layout.sectionInset.top + heightRemainder
            let bottom = layout.sectionInset.bottom + heightRemainder
            
            layout.sectionInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        }
        
        guard cardWidth > 0 && cardHeight > 0 else {
            fatalError("Too many cards to display")
        }
        
        return CGSize(width: cardWidth, height: cardHeight)
    }
    
    func getWidthHeightCardNumber(availableWidth: CGFloat, availableHeight: CGFloat) -> (widthCardNumber: CGFloat, heightCardNumber: CGFloat) {
        // find out which of gridSide1, gridSide2 makes more sense to be applied
        // to width or height in order to maximize screen space taken by the cards
        
        // landscape ratio
        if availableWidth > availableHeight {
            let availableRatio = availableWidth / availableHeight

            let gridSide = getSideWithClosestRatio(referenceRatio: availableRatio, imageSide1: imageSize.width, imageSide2: imageSize.height)

            let widthCardNumber = CGFloat(gridSide == gridSide1 ? gridSide1 : gridSide2)
            let heightCardNumber = CGFloat(gridSide == gridSide1 ? gridSide2 : gridSide1)
            
            return (widthCardNumber: widthCardNumber, heightCardNumber: heightCardNumber)
        }
            
        // portrait ratio
        let availableRatio = availableHeight / availableWidth
        
        let gridSide = getSideWithClosestRatio(referenceRatio: availableRatio, imageSide1: imageSize.height, imageSide2: imageSize.width)
        
        let heightCardNumber = CGFloat(gridSide == gridSide1 ? gridSide1 : gridSide2)
        let widthCardNumber = CGFloat(gridSide == gridSide1 ? gridSide2 : gridSide1)

        return (widthCardNumber: widthCardNumber, heightCardNumber: heightCardNumber)
    }
    
    func getSideWithClosestRatio(referenceRatio: CGFloat, imageSide1: CGFloat, imageSide2: CGFloat) -> Int {
        // get grid side that best matches the given ratio when each grid cell is an image of size imageSide1 / imageSide2
        
        let gridSide1Ratio = imageSide1 * CGFloat(gridSide1) / (imageSide2 * CGFloat(gridSide2))
        let gridSide2Ratio = imageSide1 * CGFloat(gridSide2) / (imageSide2 * CGFloat(gridSide1))

        let gridSide1IsClosest: Bool

        // both grids of images oriented in the same direction as available space
        if gridSide1Ratio >= 1 && gridSide2Ratio >= 1 {
            // pick the closest ratio
            gridSide1IsClosest = abs(gridSide1Ratio - referenceRatio) <= abs(gridSide2Ratio - referenceRatio)
        }
        else if gridSide1Ratio < 1 && gridSide2Ratio < 1{
            // none oriented correctly: pick the closest to 1
            gridSide1IsClosest = gridSide1Ratio >= gridSide2Ratio
        }
        else {
            // pick the one that is oriented in the same direction as available space
            gridSide1IsClosest = gridSide1Ratio >= 1
        }

        return gridSide1IsClosest ? gridSide1 : gridSide2
    }
}
