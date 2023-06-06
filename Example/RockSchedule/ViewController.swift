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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        map.sno = "2021215154"
        Request.request(attribute: .dataRequest(.student("2021215154"))) { response in
            switch response {
            case .success(let item):
                for course in item.values {
                    self.map.insert(course: course, with: item.key)
                }
            case .failure(let error):
                break
            }
        }
        Request.request(attribute: .dataRequest(.student("2022212832"))) { response in
            switch response {
            case .success(let item):
                for course in item.values {
                    self.map.insert(course: course, with: item.key)
                }
            case .failure(let error):
                break
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for (locate, value) in map.pointMap {
            if locate.section == 4 {
                print("\(locate) : \(value)")
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

