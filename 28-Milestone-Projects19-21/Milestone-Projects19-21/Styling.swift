//
//  Styling.swift
//  Milestone-Projects19-21
//

import UIKit

class Styling {
    static func setNavigationBarColors(for navigationController: UINavigationController?) {
        guard let navigationBar = navigationController?.navigationBar else { return }

        // background: transparent
        let emptyImage = UIImage()
        navigationBar.setBackgroundImage(emptyImage, for: .default)
        navigationBar.setBackgroundImage(emptyImage, for: .defaultPrompt)
        navigationBar.setBackgroundImage(emptyImage, for: .compact)
        navigationBar.setBackgroundImage(emptyImage, for: .compactPrompt)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
        
        // foreground
        navigationBar.tintColor = .orange
    }

    static func setToolbarColors(for navigationController: UINavigationController?) {
        guard let toolbar = navigationController?.toolbar else { return }

        // background: transparent
        toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        toolbar.isTranslucent = true
        
        // foreground
        toolbar.tintColor = .orange
    }
    
    static func setGlobalBarButtonItemStyle() {
        // bold text
        let attributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17)]
        
        UIBarButtonItem.appearance().setTitleTextAttributes(attributes, for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes(attributes, for: .application)
        UIBarButtonItem.appearance().setTitleTextAttributes(attributes, for: .disabled)
        UIBarButtonItem.appearance().setTitleTextAttributes(attributes, for: .focused)
        UIBarButtonItem.appearance().setTitleTextAttributes(attributes, for: .highlighted)
        UIBarButtonItem.appearance().setTitleTextAttributes(attributes, for: .reserved)
        UIBarButtonItem.appearance().setTitleTextAttributes(attributes, for: .selected)
    }
}
