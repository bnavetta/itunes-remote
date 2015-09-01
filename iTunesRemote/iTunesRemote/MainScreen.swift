//
//  MainScreen.swift
//  iTunesRemote
//
//  Created by Ben Navetta on 8/31/15.
//  Copyright © 2015 Ben Navetta. All rights reserved.
//

import Foundation
import UIKit

class MainViewModel: ViewModel {
    private let client = iTunesClient(server: Server(baseURL: "https://gandalf.local:5000", username: "ben", password: "avoid halo road"))
    
    func testClient() {
        self.client.artist("U2") { artist in
            switch artist {
            case .Success(let artist):
                debugPrint(artist)
            case .Failure(_, let error):
                debugPrint(error)
            }
        }
    }
}

class MainViewController: UIViewController {
    
    let viewModel: MainViewModel
    
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "MainScreen", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @IBAction
    func onClick(sender: UIButton) {
        self.viewModel.testClient()
    }
}