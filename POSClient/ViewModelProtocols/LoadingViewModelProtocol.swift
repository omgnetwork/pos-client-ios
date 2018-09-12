//
//  LoadingViewModelProtocol.swift
//  POSClient
//
//  Created by Mederic Petit on 12/9/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

protocol LoadingViewModelProtocol {
    var onFailedLoading: FailureClosure? { get set }
    var onLoadStateChange: ObjectClosure<Bool>? { get set }
    var isLoading: Bool { get set }
    var retryButtonTitle: String { get }

    func load()
}
