//
//  PreviewPictureView.swift
//  TestProject
//
//  Created by 时明 on 2017/3/14.
//  Copyright © 2017年 shiming. All rights reserved.
//

import UIKit
import SnapKit

class PreviewPictureView: UIView {
    
    //item的宽度
    fileprivate var cellWidth : CGFloat?
    //item的高度
    fileprivate var cellHeight : CGFloat?
    //当前显示的视图控制器
    fileprivate var currentVC : UIViewController?
    //collectionView
    fileprivate var imageCollectionView : UICollectionView?
    //以下是预览图片所需变量
    fileprivate var scrollView : UIScrollView?
    fileprivate var lastImageView : UIImageView?
    fileprivate var originalFrame : CGRect?
    //图片数据源
    var imageArray : [UIImage]?
    //每行的图片数
    var eachSectionCount : Int?
    //item边距值
    var margin : CGFloat?
    
    
    init(frame: CGRect,eachCount: Int,itemMargin: CGFloat) {
        super.init(frame: frame)
        
        self.frame = frame
        
        eachSectionCount = eachCount
        margin = itemMargin
        cellWidth = (frame.size.width-CGFloat(eachSectionCount!+1)*margin!)/CGFloat(eachSectionCount!)
        cellHeight = frame.size.height-2*margin!
        
        imageArray = []
        currentVC = self.getCurrentVC()
        
        self.addUI()
        self.doLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func resetFrame() {
        let remainder = (imageArray?.count)!%eachSectionCount!
        let sectionCount = remainder == 0 ? ((imageArray?.count)!/eachSectionCount!) : ((imageArray?.count)!/eachSectionCount!+1)
        var frame = self.frame
        frame.size.height = CGFloat(Int(margin!)*(sectionCount+1)+Int(cellHeight!)*sectionCount)
        self.frame = frame
    }
    
    func addUI() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: cellWidth!, height: cellHeight!)
        layout.sectionInset = UIEdgeInsets(top: margin!, left: margin!, bottom: 0, right: margin!)
        
        imageCollectionView = UICollectionView(frame: frame, collectionViewLayout:  layout)
        imageCollectionView?.register(ImageCollectionCell.self, forCellWithReuseIdentifier: "cell")
        imageCollectionView?.delegate = self
        imageCollectionView?.dataSource = self
        imageCollectionView?.backgroundColor = UIColor.clear
        
        self.addSubview(imageCollectionView!)
    }
    
    func doLayout() {
        imageCollectionView?.snp.makeConstraints({ (make) in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        })
    }
    
    func addImagesToImageArray(array: [UIImage]) {
        
        for model in array {
            self.imageArray?.append(model)
        }
        self.refreshView()
    }
    
    //添加或删除图片后刷新视图
    func refreshView() {
        imageCollectionView?.reloadData()
        self.resetFrame()
    }
    
    //获取当前显示的视图控制器
    func getCurrentVC() -> UIViewController {
        let resule : UIViewController
        var window = UIApplication.shared.keyWindow
        if window?.windowLevel != UIWindowLevelNormal {
            let windows = UIApplication.shared.windows
            for tmpWin in windows {
                if tmpWin.windowLevel == UIWindowLevelNormal {
                    window = tmpWin
                    break
                }
            }
        }
        let frontView = window?.subviews.first
        let nextRespnder = frontView?.next
        if nextRespnder is UIViewController {
            resule = nextRespnder as! UIViewController
        }else{
            resule = (window?.rootViewController)!
        }
        return resule
    }
    
    //预览图片
    func previewPicture(image: UIImage,indexPath: IndexPath) {
        let bgView = UIScrollView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        bgView.backgroundColor = UIColor.black
        bgView.isUserInteractionEnabled = true
        let recoverPicture = UITapGestureRecognizer(target: self, action: #selector(recoverPicture(tap:)))
        bgView.addGestureRecognizer(recoverPicture)
        
        let cell = self.imageCollectionView?.cellForItem(at: indexPath)
        let imageView = UIImageView(image: image)
        
        var showFrame = cell?.frame
        showFrame?.origin.y += self.frame.origin.y
        
        imageView.frame = bgView.convert(showFrame!, from: self.currentVC?.view)
        bgView.addSubview(imageView)
        
        UIApplication.shared.keyWindow?.addSubview(bgView)
        
        self.lastImageView = imageView
        self.originalFrame = showFrame!
        self.scrollView = bgView
        self.scrollView?.maximumZoomScale = 2.0
        self.scrollView?.delegate = self
        UIView.animate(withDuration: 0.5) {
            var frame = imageView.frame
            frame.size.width = bgView.frame.size.width
            frame.size.height = frame.size.width*((imageView.image?.size.height)!/(imageView.image?.size.width)!)
            frame.origin.x = 0
            frame.origin.y = (bgView.frame.size.height-frame.size.height)*0.5
            imageView.frame = frame
        }
    }
    
    //恢复图片大小
    func recoverPicture(tap: UITapGestureRecognizer) {
        self.scrollView?.contentOffset = CGPoint.zero
        UIView.animate(withDuration: 0.5, animations: {
            self.lastImageView?.frame = self.originalFrame!
            tap.view?.backgroundColor = UIColor.clear
        }) { (finisheh) in
            tap.view?.removeFromSuperview()
            self.scrollView = nil
            self.lastImageView = nil
        }
    }
}

extension PreviewPictureView:UICollectionViewDelegate,UICollectionViewDataSource{
    
    //返回多少个组
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let remainder = (imageArray?.count)!%eachSectionCount!
        if remainder != 0 {
            return (imageArray!.count)/eachSectionCount! + 1
        }
        return (imageArray!.count)/eachSectionCount!
    }
    
    //返回每组多少个cell
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        let remainder = (imageArray?.count)!%eachSectionCount!
        let sectionCount = remainder == 0 ? ((imageArray?.count)!/eachSectionCount!) : ((imageArray?.count)!/eachSectionCount!+1)
        if section == sectionCount-1 {
            return remainder == 0 ? eachSectionCount! : remainder
        }else{
            return eachSectionCount!
        }
    }
    
    //返回自定义的cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell : ImageCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ImageCollectionCell
        let image : UIImage = (imageArray?[indexPath.section*eachSectionCount!+indexPath.row])!
        cell.imgView?.image = image
        cell.deleteView?.isHidden = true
        return cell
    }
    
    //选中某个cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell : ImageCollectionCell = collectionView.cellForItem(at: indexPath) as! ImageCollectionCell
        self.previewPicture(image: (cell.imgView?.image)!,indexPath: indexPath)
        
    }
    
}

extension PreviewPictureView: UIScrollViewDelegate{
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.lastImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.lastImageView?.center = scrollView.center
        var frame = self.lastImageView?.frame
        frame?.origin.x = 0
        self.lastImageView?.frame = frame!
    }
}
