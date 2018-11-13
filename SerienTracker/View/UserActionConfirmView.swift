//
//  UserActionConfirmView.swift
//  SerienTracker
//
//  Created by Andre Frank on 12.11.18.
//  Parts of this module can be found on https://medium.com/@aatish.rajkarnikar/how-to-make-custom-alertview-dialogbox-with-animation-in-swift-3-2852f4e6f311
//
//  Copyright © 2018 Daniel Keglmeier. All rights reserved.
//


import UIKit

class UserActionConfirmView: UIView {
    private let backgroundView = UIView()
    private let userConfirmationView = UIView()
    private var title: String?
    private var message: String?
    private var image: UIImage?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    @IBInspectable var CustomImage: UIImage? {
        get { return self.image }
        set { self.image = newValue }
    }
    
    @IBInspectable var CustomTitle: String? {
        get { return self.title }
        set { self.title = newValue }
    }
    
    @IBInspectable var CustomMessage: String? {
        get { return message }
        set { message = newValue }
    }
    
    // Shouldn't be called from NIB-file
    // no title/message/image as custom properties defined
    // with IBDesignable
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViews()
    }
    
    init(title: String?, message: String?, image: UIImage?) {
        self.title = title
        self.message = message
        self.image = image
        super.init(frame: UIScreen.main.bounds)
        setupViews()
    }
    
    private func setupViews() {
        // Dark mode for background Views
        self.backgroundView.frame = frame
        self.backgroundView.backgroundColor = UIColor.black
        self.backgroundView.alpha = 0.4
        addSubview(self.backgroundView)
        
        // Configure subviews
        let dialogViewWidth = frame.width - 80
        // 1.Subview is an UILabel
        let titleLabel = UILabel(frame: CGRect(x: 8, y: 8, width: dialogViewWidth - 16, height: 30))
        titleLabel.text = title
        titleLabel.textAlignment = .center
        userConfirmationView.addSubview(titleLabel)
        
        // 2.Subview is a border view
        let separatorLineView = UIView()
        separatorLineView.frame.origin = CGPoint(x: 0, y: titleLabel.frame.height + 8)
        separatorLineView.frame.size = CGSize(width: dialogViewWidth, height: 1)
        separatorLineView.backgroundColor = UIColor.groupTableViewBackground
        userConfirmationView.addSubview(separatorLineView)
        
        // 3.Subview is an UIImage view animated or not
        let imageView = UIImageView()
        imageView.frame.origin = CGPoint(x: 8, y: separatorLineView.frame.height + separatorLineView.frame.origin.y + 8)
        imageView.frame.size = CGSize(width: dialogViewWidth - 15, height: dialogViewWidth - 15)
        imageView.image = image
        imageView.layer.cornerRadius = 4
        imageView.clipsToBounds = true
        userConfirmationView.addSubview(imageView)
        
        let dialogViewHeight = titleLabel.frame.height + 8 + separatorLineView.frame.height + 8 + imageView.frame.height + 8
        userConfirmationView.frame.origin = CGPoint(x: 32, y: frame.height)
        userConfirmationView.frame.size = CGSize(width: frame.width - 64, height: dialogViewHeight)
        userConfirmationView.backgroundColor = UIColor.white
        userConfirmationView.layer.cornerRadius = 6
        userConfirmationView.clipsToBounds = true
        addSubview(userConfirmationView)
    }
}

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
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(3000), execute: {
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
