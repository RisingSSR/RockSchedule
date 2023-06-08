//
//  ViewController.swift
//  RockSchedule
//
//  Created by RisingSSR on 05/22/2023.
//  Copyright (c) 2023 RisingSSR. All rights reserved.
//

import UIKit
import RockSchedule

class ViewController: UIViewController {
    
    let service = Service()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        view.addSubview(collecitonView)
        service.request {
            self.collecitonView.reloadData()
        }
    }
    
    lazy var collecitonView: UICollectionView = {
        let cview = service.createCollectionView(prepareWidth: view.frame.width)
        cview.frame.origin.y = 100
        cview.frame.size.height = view.frame.height - cview.frame.origin.y
        cview.isDirectionalLockEnabled = true
        cview.showsHorizontalScrollIndicator = false
        cview.showsVerticalScrollIndicator = false
        cview.decelerationRate = 0.998
        cview.backgroundColor = .red
        return cview
    }()

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
