//
//  Theme.swift
//  POSClient
//
//  Created by Mederic Petit on 17/8/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import UIKit

struct Theme {
    static func apply() {
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.barTintColor = .white
        navigationBarAppearance.tintColor = Color.black.uiColor()
        navigationBarAppearance.isTranslucent = false
        navigationBarAppearance.titleTextAttributes = [
            .font: Font.avenirMedium.withSize(20),
            .foregroundColor: Color.black.uiColor()
        ]
        let barButtonAppearance = UIBarButtonItem.appearance()
        barButtonAppearance.setTitleTextAttributes([
            .font: Font.avenirMedium.withSize(17),
            .foregroundColor: Color.black.uiColor()
        ], for: .normal)
        barButtonAppearance.setTitleTextAttributes([
            .font: Font.avenirMedium.withSize(17),
            .foregroundColor: Color.black.uiColor()
        ], for: .highlighted)
    }
}

enum Color: String {
    case black = "04070D"
    case omiseGOBlue = "1A53F0"
    case transactionDebitRed = "e74c3c"
    case transactionCreditGreen = "2ecc71"

    func uiColor(withAlpha alpha: CGFloat? = 1.0) -> UIColor {
        return UIColor.color(fromHexString: self.rawValue, alpha: alpha)
    }

    func cgColor() -> CGColor {
        return self.uiColor().cgColor
    }
}

enum Font: String {
    case avenirMedium = "Avenir-Medium"
    case avenirBook = "Avenir-Book"
    case avenirHeavy = "Avenir-Heavy"

    func withSize(_ size: CGFloat) -> UIFont {
        return UIFont(name: self.rawValue, size: size)!
    }
}
