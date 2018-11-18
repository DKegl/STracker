//
//  UserActionConfirmView.swift
//  SerienTracker
//
//  Created by Andre Frank on 12.11.18.
//  Copyright © 2018 Daniel Keglmeier. All rights reserved.
//

import Lottie
import UIKit

let addBookmarkFrames=30
let deleteBookmarkFrames=100
let displayTimeConfirmationView=600 //not including Lottie animation

class UserActionConfirmView: UIView {
    
    //MARK:- Subviews property
    // BackgroundView
    private lazy var backgroundView: UIView = {
        let bv = UIView()
        // Dark mode for background View
        bv.backgroundColor = .black
        bv.alpha = 0.4
        return bv
    }()
    
    // Main view of content subviews
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
        ml.text=_message
        return ml
    }()
    
    private lazy var titleLabel: UILabel = {
        let tl = UILabel()
        tl.numberOfLines = 1
        tl.font = UIFont(name: "Futura", size: 22)?.bold
        tl.textAlignment = .center
        tl.text=_title
        return tl
    }()
    
    private lazy var animationView: LOTAnimationView = {
        let la=LOTAnimationView()
        la.contentMode = .scaleToFill
        guard let image=_image else {return la}
        la.setAnimation(named: image)
        return la
    }()
    
    
    //MARK:- Private Properties
    private var _title: String?
    private var _message: String?
    private var _image: String?
    
    
    //MARK:- Inspectable Properties used in IB
    @IBInspectable var customImageName: String? {
        get { return self._image }
        set { self._image = newValue
            guard let imageName = newValue else { return }
            self.animationView.setAnimation(named: imageName)
        }
    }
    
    @IBInspectable var customTitle: String? {
        get { return self._title }
        set { self._title = newValue
            self.titleLabel.text = newValue
        }
    }
    
    @IBInspectable var customMessage: String? {
        get { return _message }
        set { _message = newValue
            messageLabel.text = newValue
        }
    }
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
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
   
    //This method doesn't consider size classes
    private func setupViewConstraints(){
        //Reused for all subviews
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
            
            //Swap height & width for landscape constraints
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
        
        //2.Main subview
        userConfirmationView.translatesAutoresizingMaskIntoConstraints=false
        c1 = userConfirmationView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor)
        c2 = userConfirmationView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor)
        fixedConstraints.append(contentsOf: [c1,c2])
        
        c3 = userConfirmationView.heightAnchor.constraint(equalToConstant: 200)
        c4 = userConfirmationView.widthAnchor.constraint(equalToConstant: 200)
        portraitModeConstraints.append(contentsOf: [c3,c4])
        
        c4 = userConfirmationView.heightAnchor.constraint(equalToConstant: 200)
        c5 = userConfirmationView.widthAnchor.constraint(equalToConstant: 200)
        landscapeModeConstraints.append(contentsOf: [c4,c5])
        
        //3.Title label
        titleLabel.translatesAutoresizingMaskIntoConstraints=false
        c1 = titleLabel.centerXAnchor.constraint(equalTo:userConfirmationView.centerXAnchor)
         c2 = titleLabel.topAnchor.constraint(equalTo: userConfirmationView.topAnchor, constant: 10)
         c3 = titleLabel.heightAnchor.constraint(equalToConstant: 45)
        fixedConstraints.append(contentsOf: [c1,c2])
        
        
        //4. Message label
        //currently Not used!!!!
        
        //5. animated image
        animationView.translatesAutoresizingMaskIntoConstraints=false
        c1=animationView.centerXAnchor.constraint(equalTo: userConfirmationView.centerXAnchor)
        c2=animationView.centerYAnchor.constraint(equalTo: userConfirmationView.centerYAnchor)
        c3=animationView.widthAnchor.constraint(equalToConstant: 800)
        c4=animationView.heightAnchor.constraint(equalToConstant:600)
        fixedConstraints.append(contentsOf: [c1,c2,c3,c4])
        
        
    }
    
    private func setupViews() {
        //Add subviews before building & adding constraints
        addSubview(self.backgroundView)
        backgroundView.addSubview(self.userConfirmationView)
        self.userConfirmationView.addSubview(self.titleLabel)
        self.userConfirmationView.addSubview(self.messageLabel)
        self.userConfirmationView.addSubview(self.animationView)
        //Constraints
        setupViewConstraints()
        addConstraints(fixedConstraints)
        addConstraints(portraitModeConstraints)
        addConstraints(landscapeModeConstraints)
        
        //Enable fixed constraints for different orientation modes
        _=fixedConstraints.map { $0.isActive=true}}
    
   
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


//MARK: - Show/Dismiss
extension UserActionConfirmView {
    func show(animated: Bool,frames:Int=addBookmarkFrames) {
        self.backgroundView.alpha = 0
        
        self.userConfirmationView.center = CGPoint(x: self.center.x, y: self.frame.height + self.userConfirmationView.frame.height / 2)
        UIApplication.shared.delegate?.window??.rootViewController?.view.addSubview(self)
        
        if animated {
            UIView.animate(withDuration: 0.33, animations: {
                self.backgroundView.alpha = 0.80
               
            })
            UIView.animate(withDuration: 0.33, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 10, options: UIView.AnimationOptions(rawValue: 0), animations: {
                self.userConfirmationView.center = self.center
            }, completion: { completed in
                if completed {
                    self.animationView.play(toFrame: NSNumber.init(value:frames), withCompletion: { (isCompleted) in
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(displayTimeConfirmationView), execute: {
                            self.animationView.stop()
                            self.dismiss(animated: true)
                        })
                    })
                }
            })
        } else {
            self.backgroundView.alpha = 0.80
            self.userConfirmationView.alpha = 1.0
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
