//
//  UserActionConfirmView.swift
//  SerienTracker
//
//  Created by Andre Frank on 12.11.18.
//  Copyright © 2018 Daniel Keglmeier. All rights reserved.
//

import Lottie
import UIKit

class UserActionConfirmView: UIView {
    // BackgroundView
    private lazy var backgroundView: UIView = {
        let bv = UIView()
        // Dark mode for background View
        bv.backgroundColor = .black
        bv.alpha = 0.4
        return bv
    }()
    
    // Main view of content views
    private let userConfirmationView: UIView = {
        let uv = UIView()
        uv.backgroundColor = .white
        uv.layer.cornerRadius = 6
        uv.clipsToBounds = true
        return uv
    }()
    
    // Content views
    private lazy var messageLabel: UILabel = {
        let ml = UILabel()
        ml.numberOfLines = 1
        ml.font = UIFont(name: "System", size: 14)
        ml.textAlignment = .center
        return ml
    }()
    
    private lazy var titleLabel: UILabel = {
        let tl = UILabel()
        tl.numberOfLines = 1
        tl.font = UIFont(name: "System", size: 17)
        tl.textAlignment = .center
        return tl
    }()
    
    private lazy var animationView: LOTAnimationView = {
        LOTAnimationView()
    }()
    
    private var _title: String?
    private var _message: String?
    private var _image: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    @IBInspectable var customImageName: String? {
        get { return self._image }
        set { self._image = newValue
            guard let imageName = newValue else { return }
            self.animationView.setAnimation(named: imageName)
        }
    }
    
    @IBInspectable var CustomTitle: String? {
        get { return self._title }
        set { self._title = newValue
            self.titleLabel.text = newValue
        }
    }
    
    @IBInspectable var CustomMessage: String? {
        get { return _message }
        set { _message = newValue
            messageLabel.text = newValue
        }
    }
    
    // Shouldn't be called from NIB-file
    // no title/message/image as custom properties defined
    // with IBDesignable
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViews()
    }
    
    init(title: String?, message: String?, imageName: String?) {
        self._title = title
        self._message = message
        self._image = imageName
        super.init(frame: UIScreen.main.bounds)
        self.setupViews()
    }
    private var portraitModeConstraints=[NSLayoutConstraint]()
    private var landscapeModeConstraints=[NSLayoutConstraint]()
    private var fixedConstraints=[NSLayoutConstraint]()
   
    func setupViewConstraints(){
         var c1,c2,c3,c4,c5,c6:NSLayoutConstraint
        
        // 1.Use manual layout for background view
        self.backgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        //2.Fixed constraints for Left & top
         c1 = backgroundView.leftAnchor.constraint(equalTo: self.leftAnchor)
         c2 = backgroundView.topAnchor.constraint(equalTo: self.topAnchor)
         fixedConstraints.append(contentsOf: [c1,c2])
        
       
        // 3.Dynamic constraints according to the orientation mode for width & height
        if UIDevice.current.orientation.isPortrait {
            c3 = self.backgroundView.widthAnchor.constraint(equalTo: self.widthAnchor)
            c4 = self.backgroundView.heightAnchor.constraint(equalTo: self.heightAnchor)
            // Set identifier just for debuggging purposes
            c3.identifier = "backgroundView_portraitWidth"
            c4.identifier = "backgroundView_portraitHeight"
            portraitModeConstraints.append(contentsOf: [c3, c4])
            
            c5 = self.backgroundView.widthAnchor.constraint(equalTo: self.heightAnchor)
            c6 = self.backgroundView.heightAnchor.constraint(equalTo: self.widthAnchor)
            c5.identifier = "backgroundView_landscapeWidth"
            c6.identifier = "backgroundView_landscapeHeight"
            landscapeModeConstraints.append(contentsOf: [c5, c6])
            
        } else {
            c3 = self.backgroundView.widthAnchor.constraint(equalTo: self.widthAnchor)
            c4 = self.backgroundView.heightAnchor.constraint(equalTo: self.heightAnchor)
            // Set identifier just for debugging purposes
            c3.identifier = "backgroundView_landscapeWidth"
            c4.identifier = "backgroundView_landscapeHeight"
            landscapeModeConstraints.append(contentsOf: [c3, c4])
            
            c5 = self.backgroundView.widthAnchor.constraint(equalTo: self.heightAnchor)
            c6 = self.backgroundView.heightAnchor.constraint(equalTo: self.widthAnchor)
            c5.identifier = "backgroundView_portraieWidth"
            c6.identifier = "backgroundView_portraitHeight"
            portraitModeConstraints.append(contentsOf: [c5, c6])
        }
        
        
    }
    
    private func setupViews() {
        addSubview(self.backgroundView)
        addSubview(self.userConfirmationView)
        setupViewConstraints()
        
        addConstraints(fixedConstraints)
        addConstraints(portraitModeConstraints)
        addConstraints(landscapeModeConstraints)
        
        //Fixed constraints are valid in different orieintation modes
        _=fixedConstraints.map { $0.isActive=true}
        
        self.userConfirmationView.addSubview(self.titleLabel)
        self.userConfirmationView.addSubview(self.messageLabel)
        self.userConfirmationView.addSubview(self.animationView)
    }
    
   
    override func layoutSubviews() {
        super.layoutSubviews()
        UIDevice.current.orientation.isPortrait ? self.applyPortraitLayout() : self.applyLandscapeLayout()
        
        print("layoutSubviews")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        print("traitCollectionDidChange")
    }
    
    
}

//MARK:- Orientation methods
extension UserActionConfirmView {
    private func applyLandscapeLayout() {
        _=portraitModeConstraints.map({$0.isActive=false})
        _=landscapeModeConstraints.map({$0.isActive=true})
    }
    
    private func applyPortraitLayout() {
         _=landscapeModeConstraints.map({$0.isActive=false})
        _=portraitModeConstraints.map({$0.isActive=true})
    }
    
}


//MARK: - Animation methods
extension UserActionConfirmView {
    func show(animated: Bool) {
        self.backgroundView.alpha = 0
        self.userConfirmationView.center = CGPoint(x: self.center.x, y: self.frame.height + self.userConfirmationView.frame.height / 2)
        
        UIApplication.shared.delegate?.window??.rootViewController?.view.addSubview(self)
        
        if animated {
            UIView.animate(withDuration: 0.33, animations: {
                self.backgroundView.alpha = 0.66
            })
            UIView.animate(withDuration: 0.33, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 10, options: UIView.AnimationOptions(rawValue: 0), animations: {
                self.userConfirmationView.center = self.center
            }, completion: { completed in
                if completed {
                    // self.animationView.play()
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(3000), execute: {
                        // self.animationView.stop()
                        self.dismiss(animated: true)
                    })
                }
            })
        } else {
            self.backgroundView.alpha = 0.66
            self.userConfirmationView.center = self.center
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(3000), execute: {
                self.dismiss(animated: true)
            })
        }
    }
    
    private func dismiss(animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.33, animations: {
                self.backgroundView.alpha = 0
            }, completion: { _ in
                
            })
            UIView.animate(withDuration: 0.33, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 10, options: UIView.AnimationOptions(rawValue: 0), animations: {
                self.userConfirmationView.center = CGPoint(x: self.center.x, y: self.frame.height + self.userConfirmationView.frame.height / 2)
            }, completion: { _ in
                self.removeFromSuperview()
            })
        } else {
            self.removeFromSuperview()
        }
    }
}
