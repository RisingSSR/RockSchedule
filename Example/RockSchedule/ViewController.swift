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
        Request.request(attribute: .dataRequest(.student("2021215154"))) { item in
            print(item)
            for course in item.values {
                self.map.map(course: course, with: item.key)
            }
        }
        
        Request.request(attribute: .dataRequest(.student("2022212832"))) { item in
            print(item)
            for course in item.values {
                self.map.map(course: course, with: item.key)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for (locate, value) in map.pointMap {
            if locate.section == 4 {
                print("\(locate) : \(value)")
            }
        }
        for (section, sets) in map.finalSet {
            
            if section == 4 {
                
                print("section \(section)")
                
                for set in sets {
                    print("\(set.locate): \(set.node)")
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

