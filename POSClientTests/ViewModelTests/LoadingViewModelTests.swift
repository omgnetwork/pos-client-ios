//
//  LoadingViewModelTests.swift
//  POSClientTests
//
//  Created by Mederic Petit on 31/8/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

@testable import OmiseGO
@testable import POSClient
import XCTest

class LoadingViewModelTests: XCTestCase {
    var sessionManager: TestSessionManager!
    var sut: LoadingViewModel!

    override func setUp() {
        super.setUp()
        self.sessionManager = TestSessionManager()
        self.sut = LoadingViewModel(sessionManager: self.sessionManager)
    }

    override func tearDown() {
        self.sessionManager = nil
        self.sut = nil
        super.tearDown()
    }

    func testLoadCalled() {
        self.sut.load()
        XCTAssertTrue(self.sessionManager.loadCurrentUserCalled)
        XCTAssertTrue(self.sessionManager.loadWalletCalled)
    }

    func testLoadCurrentUserFailed() {
        let expectation = self.expectation(description: "fails to load current user calls onFailedLoading with the correct error")
        var didFail = false
        self.sut.onFailedLoading = {
            defer { expectation.fulfill() }
            XCTAssertEqual($0.message, "unexpected error: Failed to load user")
            didFail = true
        }
        self.sut.load()
        self.sessionManager.loadWalletSuccess()
        let error: OMGError = .unexpected(message: "Failed to load user")
        self.sessionManager.loadCurrentUserFailed(withError: error)
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssertNotNil(self.sut.raisedError)
        XCTAssertEqual(error.message, self.sut.raisedError!.message)
        XCTAssert(didFail)
    }

    func testLoadWalletFailed() {
        let expectation = self.expectation(description: "fails to load wallet calls onFailedLoading with the correct error")
        var didFail = false
        self.sut.onFailedLoading = {
            defer { expectation.fulfill() }
            XCTAssertEqual($0.message, "unexpected error: Failed to load wallet")
            didFail = true
        }
        self.sut.load()
        self.sessionManager.loadCurrentUserSuccess()
        let error: OMGError = .unexpected(message: "Failed to load wallet")
        self.sessionManager.loadWalletFailed(withError: error)
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssertNotNil(self.sut.raisedError)
        XCTAssertEqual(error.message, self.sut.raisedError!.message)
        XCTAssert(didFail)
    }

    func testLoadBothFailedTakesTheLastError() {
        let expectation = self.expectation(description: "fails to load wallet and user calls onFailedLoading with the correct error")
        var didFail = false
        self.sut.onFailedLoading = {
            defer { expectation.fulfill() }
            XCTAssertEqual($0.message, "unexpected error: Failed to load wallet")
            didFail = true
        }
        self.sut.load()
        self.sessionManager.loadCurrentUserFailed(withError: .unexpected(message: "Failed to load user"))
        let error: OMGError = .unexpected(message: "Failed to load wallet")
        self.sessionManager.loadWalletFailed(withError: error)
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssertNotNil(self.sut.raisedError)
        XCTAssertEqual(error.message, self.sut.raisedError!.message)
        XCTAssert(didFail)
    }

    func testLoadSucceed() {
        let expectation = self.expectation(description: "Successful load call removeObserver")
        self.sut.load()
        self.sessionManager.loadCurrentUserSuccess()
        self.sessionManager.loadWalletSuccess()
        dispatchMain { expectation.fulfill() }
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(self.sessionManager.removeObserverCalled)
        XCTAssertNil(self.sut.raisedError)
    }

    func testCallsClearTokensWhenRaisingAnAuthenticationError() {
        let expectation = self.expectation(description: "Failure with an authentication error calls clearToken")
        self.sut.onFailedLoading = { _ in expectation.fulfill() }
        self.sut.load()
        let apiError = APIError(code: .authenticationTokenExpired, description: "")
        XCTAssertTrue(apiError.isAuthorizationError())
        let error: OMGError = .api(apiError: apiError)
        self.sessionManager.loadCurrentUserFailed(withError: error)
        self.sessionManager.loadWalletFailed(withError: error)
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(self.sessionManager.clearTokenCalled)
    }

    func testHideLoadingWhenRequestFails() {
        let expectation = self.expectation(description: "Hides loading when request fails")
        var loadingStatus = false
        self.sut.onLoadStateChange = {
            loadingStatus = $0
            if !loadingStatus { expectation.fulfill() }
        }
        self.sut.load()
        XCTAssertTrue(loadingStatus)
        self.sessionManager.loadCurrentUserSuccess()
        self.sessionManager.loadWalletFailed(withError: .unexpected(message: ""))
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssertFalse(loadingStatus)
    }

    func testUserUpdateTriggersGroupLeave() {
        var didLeave = false
        let expectation = self.expectation(description: "onUserUpdate event triggers group leave")
        self.sut.dispatchGroup.enter()
        dispatchGlobal {
            self.sut.dispatchGroup.wait()
            dispatchMain {
                didLeave = true
                expectation.fulfill()
            }
        }
        self.sut.onChange(event: .onUserUpdate(user: StubGenerator.currentUser()))
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didLeave)
    }

    func testWalletUpdateTriggersGroupLeave() {
        var didLeave = false
        let expectation = self.expectation(description: "onWalletUpdate event triggers group leave")
        self.sut.dispatchGroup.enter()
        dispatchGlobal {
            self.sut.dispatchGroup.wait()
            dispatchMain {
                didLeave = true
                expectation.fulfill()
            }
        }
        self.sut.onChange(event: .onWalletUpdate(wallet: StubGenerator.mainWallet()))
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didLeave)
    }

    func testUserUpdateFailureTriggersGroupLeave() {
        var didLeave = false
        let expectation = self.expectation(description: "onUserError event triggers group leave and set raisedError")
        self.sut.dispatchGroup.enter()
        dispatchGlobal {
            self.sut.dispatchGroup.wait()
            dispatchMain {
                didLeave = true
                expectation.fulfill()
            }
        }
        let error: OMGError = .unexpected(message: "error")
        self.sut.onChange(event: .onUserError(error: error))
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didLeave)
        XCTAssertNotNil(self.sut.raisedError)
        XCTAssertEqual(self.sut.raisedError!.message, error.message)
    }

    func testWalletUpdateFailureTriggersGroupLeave() {
        var didLeave = false
        let expectation = self.expectation(description: "onWalletError event triggers group leave and set raisedError")
        self.sut.dispatchGroup.enter()
        dispatchGlobal {
            self.sut.dispatchGroup.wait()
            dispatchMain {
                didLeave = true
                expectation.fulfill()
            }
        }
        let error: OMGError = .unexpected(message: "error")
        self.sut.onChange(event: .onWalletError(error: error))
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didLeave)
        XCTAssertNotNil(self.sut.raisedError)
        XCTAssertEqual(self.sut.raisedError!.message, error.message)
    }
}
