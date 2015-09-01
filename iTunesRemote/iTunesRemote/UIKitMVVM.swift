//
//  UIKitMVVM.swift
//  iTunesRemote
//
//  Created by Ben Navetta on 8/31/15.
//  Copyright © 2015 Ben Navetta. All rights reserved.
//

import Foundation
import UIKit

class UIKitNavigator: BaseNavigator, Navigator {
    private weak var controller: UINavigationController?
    
    var history = [ViewModel]()
    
    init(controller: UINavigationController) {
        self.controller = controller
    }
    
    func makeCurrent(viewModel: ViewModel) {
        controller?.pushViewController(createViewController(viewModel), animated: true)
    }
    
    private func createViewController(viewModel: ViewModel) -> UIViewController {
        switch viewModel {
        case let vm as MainViewModel:
            return MainViewController(viewModel: vm)
        default:
            fatalError("Unknown ViewModel instance: \(viewModel)")
        }
    }
}