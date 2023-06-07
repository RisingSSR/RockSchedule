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
    
    var map = Map()
    let service = Service()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        map.sno = "2021215154"
        view.addSubview(collecitonView)
        
        Request.request(attributes: [
            .dataRequest(.student("2021215154")),
            .dataRequest(.student("2022212832"))
        ]) { response in
            switch response {
            case .success(let items):
                for item in items {
                    print("\(item.key.sno)")
                    for course in item.values {
                        self.map.insert(course: course, with: item.key)
                    }
                }
                
                self.collecitonView.reloadData()
                
            case .failure(let error):
                break
            }
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for (locate, value) in map.pointMap {
            if locate.section == 4 {
                print("\(locate) : \(value)")
            }
        }
        
        for (node, idxary) in map.nodeMap {
            print("\(node)")
            for i in 0..<idxary.count where idxary[i] != nil {
                let each = idxary[i]!
                print("\t\(i)", terminator: " ")
                for range in each.rangeView {
                    print("\t\t\(range)", terminator: " ")
                }
                print("")
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

