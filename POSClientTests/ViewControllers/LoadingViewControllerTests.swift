//
//  LoadingViewControllerTests.swift
//  POSClientTests
//
//  Created by Mederic Petit on 6/9/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

@testable import POSClient
import Toaster
import XCTest

class LoadingViewControllerTests: XCTestCase {
    var sut: LoadingViewController!

    override func setUp() {
        super.setUp()
        self.sut = Storyboard.loading.storyboard.instantiateViewController(withIdentifier: "LoadingViewController") as! LoadingViewController
        _ = self.sut.view
    }

    override func tearDown() {
        super.tearDown()
        ToastCenter.default.cancelAll()
        self.sut = nil
    }

    func testSetupsCorrectly() {
        XCTAssertEqual(self.sut.retryButton.titleLabel?.text, self.sut.viewModel.retryButtonTitle)
        XCTAssertTrue(self.sut.retryButton.isHidden)
    }

    func testFailedLoadinShowsError() {
        let error = POSClientError.unexpected
        self.sut.viewModel.onFailedLoading?(error)
        XCTAssertEqual(ToastCenter.default.currentToast!.text, error.message)
    }

    func testLoadStateChangeTriggersLoadingAndRetryButtonVisibiliyChange() {
        self.sut.viewModel.onLoadStateChange?(true)
        XCTAssertTrue(self.sut.loadingImageView.isAnimating)
        XCTAssertTrue(self.sut.retryButton.isHidden)
        self.sut.viewModel.onLoadStateChange?(false)
        XCTAssertFalse(self.sut.loadingImageView.isAnimating)
        XCTAssertFalse(self.sut.retryButton.isHidden)
    }
}
