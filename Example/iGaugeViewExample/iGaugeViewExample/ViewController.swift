//
//  ViewController.swift
//  iGaugeViewExample
//
//  Created by Farshad.Jahanmanesh on 31.07.2018.
//  Copyright © 2018 Farshad.Jahanmanesh. All rights reserved.
//

import UIKit
class ViewController: UIViewController {
    @IBOutlet weak var gauge : iGaugeView?
    override func viewDidLoad() {
        super.viewDidLoad()
        var options = iGaugeViewOptions()
        options.animationDuration = 0.2
        options.colorsStrocks.mainCircle = UIColor.gray
        options.colorsFill.pointer = .white
        options.strocks.mainCircle = 40
        options.colorsStrocks.highlighter = UIColor.red
        options.colorsStrocks.pointer = .white
        options.colorsStrocks.numbers = .white
        options.strocks.innerSeperator = 2
        options.strocks.mainSeperator = 2
        options.minShowableValue = 0
        options.steps = 8
        options.maxShowableValue = 64
        options.isMainCircleFullCircle = false
        gauge?.setup(options: options, withAnimation: true)
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { (timer) in
            self.gauge?.set(currentValue: CGFloat(arc4random_uniform(UInt32(options.maxShowableValue))))
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

