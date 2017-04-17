//
//  ImageScrollView.swift
//  ImageSelectProject
//
//  Created by 时明 on 2017/4/15.
//  Copyright © 2017年 shiming. All rights reserved.
//

import UIKit

class ImageScrollView: UIView {

    let SCREEN_WIDTH = UIScreen.main.bounds.size.width
    let SCREEN_HEIGHT = UIScreen.main.bounds.size.height
    
    var dataSourceArr = [UIImage]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black
        
        self.addSubview(imgScrollView)
        imgScrollView.snp.makeConstraints { (make) in
            make.top.bottom.left.right.equalToSuperview()
        }
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    func addImagesToScrollView(tag: Int){
        for view in imgScrollView.subviews {
            view.removeFromSuperview()
        }
        
        imgScrollView.contentSize = CGSize(width: SCREEN_WIDTH*CGFloat(dataSourceArr.count), height: SCREEN_HEIGHT)

        var index = CGFloat(0.0)
        for image in dataSourceArr {
            let subScrollView = UIScrollView(frame: CGRect(x: index*SCREEN_WIDTH, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
            subScrollView.delegate = self
            subScrollView.maximumZoomScale = 3
            subScrollView.minimumZoomScale = 1
            
            let imageView = UIImageView(image: image)
            imageView.contentMode = UIViewContentMode.scaleAspectFit
            imageView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
            imageView.tag = 10
            subScrollView.tag = Int(index) + 100
            
            subScrollView.addSubview(imageView)
            imgScrollView.addSubview(subScrollView)
            
            index += 1.0
        }
        
        imgScrollView.contentOffset = CGPoint(x: CGFloat(tag)*SCREEN_WIDTH, y: 0)
    }
    
    lazy fileprivate var imgScrollView : UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        return scrollView
    }()
    
}

extension ImageScrollView: UIScrollViewDelegate{
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == imgScrollView {
            let index = Int(scrollView.contentOffset.x/UIScreen.main.bounds.size.width)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeImage"), object: self, userInfo: ["value": index])
            
            for view in imgScrollView.subviews {
                view.removeFromSuperview()
            }
            
            var num = CGFloat(0.0)
            for image in dataSourceArr {
                let subScrollView = UIScrollView(frame: CGRect(x: num*SCREEN_WIDTH, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
                subScrollView.delegate = self
                subScrollView.maximumZoomScale = 3
                subScrollView.minimumZoomScale = 1
                
                let imageView = UIImageView(image: image)
                imageView.contentMode = UIViewContentMode.scaleAspectFit
                imageView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
                imageView.tag = 10
                subScrollView.tag = Int(num) + 100
                
                subScrollView.addSubview(imageView)
                imgScrollView.addSubview(subScrollView)
                
                num += 1.0
            }
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if scrollView != self.imgScrollView {
            let i = Int(imgScrollView.contentOffset.x/(UIScreen.main.bounds.size.width))
            let subScrollView = imgScrollView.viewWithTag(100+i)
            let iView = subScrollView?.viewWithTag(10)
            return iView
        }
        return nil
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if scrollView != imgScrollView {
            scrollView.setZoomScale(scale, animated: false)
        }
    }
}


