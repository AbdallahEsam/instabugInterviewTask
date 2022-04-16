//
//  ViewController.swift
//  InstabugInterview
//
//  Created by Yousef Hamza on 1/13/21.
//

import UIKit
import InstabugNetworkClient

class ViewController: UIViewController {

    var repo: AppRepoProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        
        repo = AppRepo()
        repo.get { [weak self] data in
            print(data)
        }
    }
    

}

