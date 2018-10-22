//
//  SignupConfirmationViewControllerTests.swift
//  POSClientTests
//
//  Created by Mederic Petit on 11/9/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

@testable import POSClient
import XCTest

class SignupConfirmationViewControllerTests: XCTestCase {
    var sut: SignupConfirmationViewController!

    override func setUp() {
        super.setUp()
        self.sut =
            Storyboard.signup.storyboard.instantiateViewController(withIdentifier: "SignupConfirmationViewController") as? SignupConfirmationViewController
        _ = UINavigationController(rootViewController: self.sut)
        _ = self.sut.view
    }

    override func tearDown() {
        super.tearDown()
        self.sut = nil
    }

    func testSetupsCorrectly() {
        XCTAssertEqual(self.sut.titleLabel.text, self.sut.viewModel.title)
        XCTAssertEqual(self.sut.hintLabel.text, self.sut.viewModel.hint)
        XCTAssertEqual(self.sut.gotItButton.titleLabel?.text, self.sut.viewModel.gotItButtonTitle)
    }

    func testTapGotItPopsToRoot() {
        let dummyVC = UIViewController(nibName: nil, bundle: nil)
        let navVC = UINavigationController(rootViewController: dummyVC)
        navVC.pushViewController(self.sut, animated: false)
        XCTAssertEqual(navVC.viewControllers.count, 2)
        self.sut.tapGotItButton(self.sut.gotItButton)
        XCTAssertEqual(navVC.viewControllers.count, 1)
        XCTAssertEqual(navVC.viewControllers[0], dummyVC)
    }

    func testPopsToRootWhenAppEnterForeground() {
        let dummyVC = UIViewController(nibName: nil, bundle: nil)
        let navVC = UINavigationController(rootViewController: dummyVC)
        navVC.pushViewController(self.sut, animated: false)
        XCTAssertEqual(navVC.viewControllers.count, 2)
        NotificationCenter.default.post(name: UIApplication.willEnterForegroundNotification, object: nil)
        XCTAssertEqual(navVC.viewControllers.count, 1)
        XCTAssertEqual(navVC.viewControllers[0], dummyVC)
    }
}
