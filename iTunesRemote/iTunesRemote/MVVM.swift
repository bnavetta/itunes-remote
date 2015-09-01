//
//  MVVM.swift
//  iTunesRemote
//
//  Created by Ben Navetta on 8/31/15.
//  Copyright © 2015 Ben Navetta. All rights reserved.
//

import Foundation

protocol ViewModel: class {
    
}

protocol Navigator {
    var history: [ViewModel] { get }
    mutating func goTo(viewModel: ViewModel)
    mutating func goBack()
}

protocol BaseNavigator {
    var history: [ViewModel] { get set }
    func makeCurrent(viewModel: ViewModel)
}

extension Navigator where Self: BaseNavigator {
    mutating func goTo(viewModel: ViewModel) {
        history.append(viewModel)
        makeCurrent(viewModel)
    }
    
    mutating func goBack() {
        history.removeLast()
        if let previous = history.last {
            makeCurrent(previous)
        }
    }
}
