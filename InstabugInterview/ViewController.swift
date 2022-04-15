//
//  ViewController.swift
//  InstabugInterview
//
//  Created by Yousef Hamza on 1/13/21.
//

import UIKit
import InstabugNetworkClient

class ViewController: UIViewController {

     
    
    override func viewDidLoad() {
        super.viewDidLoad()


        let network = NetworkFactory.getNetwok()
        
        network.get(.init(string: "https://httpbin.org")!) {  [weak self] data in
            print(data)
        }

    }
    
    
   


}

