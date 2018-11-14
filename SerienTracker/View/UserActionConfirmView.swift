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
   
    private var messageLabel:UILabel!
    private var titleLabel:UILabel!
    private var imageView:UIImageView!
    
    private var _title: String?
    private var _message: String?
    private var _image: UIImage?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    @IBInspectable var CustomImage: UIImage? {
        get { return self._image }
        set { self._image = newValue
              imageView.image = newValue
        }
    }
    
    @IBInspectable var CustomTitle: String? {
        get { return self._title }
        set { self._title = newValue
             titleLabel.text = newValue
        }
    }
    
    @IBInspectable var CustomMessage: String? {
        get { return _message }
        set { _message = newValue
            messageLabel.text=newValue
        }
    }
    
    // Shouldn't be called from NIB-file
    // no title/message/image as custom properties defined
    // with IBDesignable
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViews()
    }
    
    init(title: String?, message: String?, image: UIImage?) {
        self._title = title
        self._message = message
        self._image = image
        super.init(frame: UIScreen.main.bounds)
        self.setupViews()
    }
    
    private func setupViews() {
        // Dark mode for background Views
        self.backgroundView.frame = frame
        self.backgroundView.backgroundColor = UIColor.black
        self.backgroundView.alpha = 0.4
        addSubview(self.backgroundView)
        
        // Configure subviews
        let dialogViewWidth = frame.width - 150
        // 1.Subview is an UILabel
        titleLabel = UILabel(frame: CGRect(x:frame.width/2-dialogViewWidth/2-4, y: 8, width: dialogViewWidth - 16, height: 30))
        titleLabel.text = _title
        titleLabel.textAlignment = .center
        userConfirmationView.addSubview(titleLabel)
        
        // 2.Subview is an UILabel
        messageLabel = UILabel(frame: CGRect(x: frame.width/2-dialogViewWidth/2-4, y: titleLabel.frame.height+8, width: dialogViewWidth - 16, height: 30))
        messageLabel.text = _title
        messageLabel.textAlignment = .center
        userConfirmationView.addSubview(messageLabel)
        
        // 3.Subview is an UIImage view animated or not
        imageView = UIImageView()
        let yOrigin=messageLabel.frame.height+messageLabel.frame.origin.y+CGFloat(8)
        imageView.frame.origin = CGPoint(x:dialogViewWidth/2+20, y:yOrigin)
        imageView.frame.size = CGSize(width:40 , height:40)
        imageView.contentMode = .scaleAspectFit
        imageView.image = _image
        imageView.layer.cornerRadius = 4
        imageView.clipsToBounds = true
        userConfirmationView.addSubview(imageView)
        
        var dialogViewHeight = titleLabel.frame.height + 8 + imageView.frame.height + 8
        dialogViewHeight += (messageLabel.frame.height + 8)
        userConfirmationView.frame.origin = CGPoint(x: 32, y: frame.height)
        userConfirmationView.frame.size = CGSize(width:frame.width-64, height: dialogViewHeight)
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
