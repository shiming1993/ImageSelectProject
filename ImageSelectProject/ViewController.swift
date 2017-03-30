//
//  ViewController.swift
//  ImageSelectProject
//
//  Created by 时明 on 2017/3/29.
//  Copyright © 2017年 shiming. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //初始化ImageSelectView,设置frame，每一行照片数，照片间距值
        let view = ImageSelectView(frame: CGRect(x: 0, y: 40, width: self.view.frame.size.width, height: 100), eachCount: 4, itemMargin: 10)
        view.delegate = self
        //设置最大照片数
        //view.maxNumber = 9
        //设置选择照片来源
        //view.selectPictureType = SelectType.SELECT_BOTH
        //是否支持水印文字
        //view.watermarkEnable = true
        //水印文字内容
        //view.watermarkArray = ["我要打水印","这是一个水印文字"]
        //可以预先加入一些图片
        view.addImagesToImageArray(array: [])
        self.view.addSubview(view)
        
        
        
        //PreviewPictureView是单纯的预览图片的控件，不可编辑
        let previewView = PreviewPictureView(frame: CGRect(x: 0, y: 170, width: self.view.frame.size.width, height: 100), eachCount: 4, itemMargin: 10)
        //添加要查看的图片
        previewView.addImagesToImageArray(array: [])
        self.view.addSubview(view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//代理方法
extension ViewController: ImageSelectViewDelegate{
    
    func getCurrentHeight(selectView: ImageSelectView, height: CGFloat) {
        
    }
    
    func willAddImage(selectView: ImageSelectView) {
        
    }
    
    func didAddImage(selectView: ImageSelectView, image: UIImage) {
        
    }
    
    func deleteImage(selectView: ImageSelectView, image: UIImage, index: Int) {
        
    }
    
    
}
