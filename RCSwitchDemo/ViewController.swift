//
//  ViewController.swift
//  RCSwitchDemo
//
//  Created by Developer on 2016/12/19.
//  Copyright © 2016年 Beijing Haitao International Travel Service Co., Ltd. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var aSwitch: RCSwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        aSwitch = RCSwitch(frame: CGRect(x: 100, y: 100, width: 60, height: 25))
        aSwitch.onText = "Abc"
//        aSwitch.offText = "xyz"
        self.view.addSubview(aSwitch)


        let btn = UIButton(type: .custom)
        btn.setTitle("didi", for: .normal)
        btn.frame = CGRect(x: 10, y: 300, width: 300, height: 30)
        btn.addTarget(self, action: #selector(click), for: .touchUpInside)
        view.addSubview(btn)
    }

    func click() {
        aSwitch.onText = "Abc"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

