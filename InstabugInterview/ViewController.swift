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
    let storage = StorageManager.shared
    private let rootQueue: DispatchQueue = DispatchQueue(label: "com.instabug.session.testQueque")
    let dispatchGroup = DispatchGroup()
    override func viewDidLoad() {
        super.viewDidLoad()
            
        
        repo = AppRepo()
        repo.get { [weak self] data in
            print(data)
        }
        
        DispatchQueue.main.async {
            self.repo.get { [weak self] data in
                print(data)
            }
            
        }
        
        rootQueue.async(group: dispatchGroup) {
            for x in 1000...2000{
                self.storage.saveRecord(with: .init(creationDate: nil, method: nil, url: nil, statusCode: x, requestPayload: nil, responsePayload: nil, errorDomain: nil), compeletion: {_ in })
            }
        }
        
        rootQueue.async(group: dispatchGroup) {
            for x in 0...1000{
                self.storage.saveRecord(with: .init(creationDate: nil, method: nil, url: nil, statusCode: x, requestPayload: nil, responsePayload: nil, errorDomain: nil), compeletion: {_ in })
            }
        }
       
        
        
        dispatchGroup.notify(queue: DispatchQueue.main) {
            self.storage.fetchRecords { [weak self] result in
                switch result {
                case .success(let records):
                    print(records.map({$0.statusCode}))
                    print(records.count)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    

}

