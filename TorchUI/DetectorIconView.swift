//
//  PropertyIconView.swift
//  TorchUI
//
//  Created by Parth Saxena on 7/7/23.
//

import Foundation
import UIKit

class DetectorIconView: UIView {
    @IBOutlet weak var detectorImageView: UIImageView!
    @IBOutlet weak var detectorLabel: UILabel!
    @IBOutlet weak var detectorMainView: UIView!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    var detectorName = ""
    
    static var instantiated = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
//                commonInit()
    }
    
    func configure(with detectorName: String, threat: Threat) {
        self.detectorLabel.text = detectorName
//        self.propertyLabel.adjustsFontSizeToFitWidth = true
//        self.propertyLabel.numberOfLines = 1
//        self.propertyLabel.sizeToFit()
//        self.widthConstraint.constant = self.propertyLabel.frame.size.width
        if threat == Threat.Red {
            self.detectorImageView.image = UIImage(named: "DetectorIcons/ThreatRed")
        } else if threat == Threat.Yellow {
            self.detectorImageView.image = UIImage(named: "DetectorIcons/ThreatYellow")
        }

        self.layoutIfNeeded() // Trigger layout update after changing content
    }
    
    class func instanceFromNib() -> DetectorIconView {
        let view = UINib(nibName: "DetectorIconView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! DetectorIconView
        return view
    }
        
    
    fileprivate func setupView() {
            // do your setup here
//        propertyLabel.text = propertyName
        
//        // print("bounds: \(self.bounds)")
//        // print(self.propertyImageView.image)
    }
    
//    override func viewDidAp
    
//    func commonInit() {
////            // print("hello world")
//
//        if PropertyIconView.instantiated {
//            return
//        }
//
//        PropertyIconView.instantiated = true
//
//        let viewFromXib = Bundle.main.loadNibNamed("PropertyIconView", owner: self, options: nil)![0] as! PropertyIconView
//        viewFromXib.frame = self.bounds
//        viewFromXib.autoresizingMask = [.flexibleWidth, .flexibleHeight]
////        self.propertyMainView.layer.cornerRadius = self.bounds.height / 2
//        addSubview(viewFromXib)
////        self.view.frame = self.bounds
////        setupView()
//        // print("bounds: \(viewFromXib.bounds)")
//
//    }
    
}
