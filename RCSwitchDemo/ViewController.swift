//
//  ViewController.swift
//  RCSwitchDemo
//
//  Created by Developer on 2016/12/19.
//  Copyright © 2016年 Beijing Haitao International Travel Service Co., Ltd. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let aSwitch = RCSwitch(frame: CGRect(x: 100, y: 100, width: 60, height: 25), text: "Abc")
        self.view.layer.addSublayer(aSwitch.shadowLayer)
        self.view.addSubview(aSwitch)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

