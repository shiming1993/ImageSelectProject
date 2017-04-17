//
//  ImageSelectView.swift
//  TestProject
//
//  Created by 时明 on 2017/3/9.
//  Copyright © 2017年 shiming. All rights reserved.
//

import UIKit
import SnapKit


protocol ImageSelectViewDelegate {
    func getCurrentHeight(selectView:ImageSelectView, height: CGFloat)
    func willAddImage(selectView:ImageSelectView)
    func didAddImage(selectView:ImageSelectView, image: UIImage)
    func deleteImage(selectView:ImageSelectView, image: UIImage,index: Int)
}

enum SelectType{
    //从相机获取照片
    case SELECT_CAMERA
    //从相册获取照片
    case SELECT_PHTOTO_LIBRARY
    //从相机和相册获取
    case SELECT_BOTH
}

class ImageSelectView: UIView {
    
    var delegate : ImageSelectViewDelegate?
    //topMargin
    var margin : CGFloat?
    //图片数据源
    var imageArray : [UIImage]?
    //选择照片途径,默认从相机和相册选择
    var selectPictureType : SelectType = SelectType.SELECT_BOTH
    //最大照片数,默认9张
    var maxNumber : Int = 9
    //是否支持打水印，默认为false
    var watermarkEnable = false
    //水印文字
    var watermarkArray : [NSString]?
    //水印文字颜色
    var waterMarkColor : UIColor = UIColor.blue
    //水印文字大小
    var waterMarkFont : CGFloat = 100.0
    //每行图片数目
    var eachSectionCount : Int?
    
    //item的宽度
    fileprivate var cellWidth : CGFloat?
    //item的高度
    fileprivate var cellHeight : CGFloat?
    //collectionView
    fileprivate var imageCollectionView : UICollectionView?
    fileprivate var alertVC : UIAlertController?
    //当前显示的视图控制器
    fileprivate var currentVC : UIViewController?
    //UIImagePickerController
    fileprivate var pickerVC : UIImagePickerController?
    //以下是预览图片所需变量
    fileprivate var showScrollView = ImageScrollView()
    fileprivate var bgView : UIView?
    fileprivate var laseImageView : UIImageView?
    fileprivate var originalFrame : CGRect?
    //记录数组中是否有添加图片的image
    fileprivate var hasAddImage = true
    
    
    
    
    init(frame: CGRect,eachCount: Int,itemMargin: CGFloat) {
        super.init(frame: frame)
        
        self.frame = frame
        
        eachSectionCount = eachCount
        margin = itemMargin
        let w = Int((frame.size.width-CGFloat(eachSectionCount!+1)*margin!)/CGFloat(eachSectionCount!))
        cellWidth = CGFloat(w)
        cellHeight = frame.size.height-2*margin!
        
        imageArray = []
        watermarkArray = []
        imageArray?.append(UIImage(named: "addImage")!)
        currentVC = getCurrentVC()
        
        self.addUI()
        self.createImagePickerController()
        self.createAlertCtr()
        self.doLayout()
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeImage(noti:)), name: NSNotification.Name(rawValue: "changeImage"), object: nil)
        bgView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        bgView!.backgroundColor = UIColor.black
        showScrollView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        showScrollView.isUserInteractionEnabled = true
        let recoverPicture = UITapGestureRecognizer(target: self, action: #selector(recoverPicture(tap:)))
        showScrollView.addGestureRecognizer(recoverPicture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func changeImage(noti: Notification){
        let index = noti.userInfo?["value"] as! Int
        let section = index/eachSectionCount!
        let row = index%eachSectionCount!
        let indexPath = NSIndexPath(row: row, section: section)
        let cell : ImageCollectionCell = imageCollectionView?.cellForItem(at: indexPath as IndexPath) as! ImageCollectionCell
        //获取cell相对于整个屏幕的位置
        let window = UIApplication.shared.keyWindow
        let rect = cell.convert((cell.bounds), to: window)
        
        self.laseImageView?.image = cell.imgView?.image
        self.originalFrame = rect
    }
    
    func resetFrame() {
        let remainder = (imageArray?.count)!%eachSectionCount!
        let sectionCount = remainder == 0 ? ((imageArray?.count)!/eachSectionCount!) : ((imageArray?.count)!/eachSectionCount!+1)
        var frame = self.frame
        frame.size.height = CGFloat(Int(margin!)*(sectionCount+1)+Int(cellHeight!)*sectionCount)
        self.frame = frame
        self.delegate?.getCurrentHeight(selectView: self,height: frame.size.height)
    }
    
    func addUI() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: cellWidth!, height: cellHeight!)
        layout.sectionInset = UIEdgeInsets(top: margin!, left: margin!, bottom: 0, right: margin!)
        
        imageCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height), collectionViewLayout:  layout)
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
        
        self.imageArray?.removeAll()
        var index = 0
        while index < array.count {
            let image = array[index]
            self.imageArray?.append(image)
            index += 1
            if index == maxNumber {
                break
            }
        }
        if index < maxNumber {
            self.imageArray?.append( UIImage(named: "addImage")!)
        }else{
            self.hasAddImage = false
        }
        
        self.refreshView()
    }
    
    
    func createAlertCtr() {
        alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "拍照", style: .default) { (action) in
            self.takePhoto()
        }
        let phtotAction = UIAlertAction(title: "相册", style: .default) { (action) in
            self.intoPhotoLibrary()
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (action) in
            //
        }
        alertVC?.addAction(cameraAction)
        alertVC?.addAction(phtotAction)
        alertVC?.addAction(cancelAction)
    }
    
    func createImagePickerController() {
        pickerVC = UIImagePickerController()
        pickerVC?.view.backgroundColor = UIColor.white
        pickerVC?.delegate = self
        //pickerVC?.allowsEditing = true
    }
    
    //添加或删除图片后刷新视图
    func refreshView() {
        imageCollectionView?.reloadData()
        self.resetFrame()
    }
    
    //拍照
    func takePhoto() {
        pickerVC?.sourceType = .camera
        //waterMarkFont = 110.0
        self.currentVC?.present(pickerVC!, animated: true, completion: nil)
    }
    
    //进入相册
    func intoPhotoLibrary() {
        pickerVC?.sourceType = .photoLibrary
        //waterMarkFont = 60.0
        self.currentVC?.present(pickerVC!, animated: true, completion: nil)
    }
    
    //手势事件
    //删除图片
    func deleteImage(tap: UITapGestureRecognizer){
        let tag = tap.view?.tag
        self.delegate?.deleteImage(selectView: self,image: (imageArray?[tag!])!,index: tag!)
        imageArray?.remove(at: tag!)
        if imageArray?.count == maxNumber-1 && !hasAddImage{
            imageArray?.append(UIImage(named: "addImage")!)
            hasAddImage = true
        }
        self.refreshView()
    }
    
    //预览图片
    func previewPicture(image: UIImage,indexPath: IndexPath) {
        
        let tag = indexPath.section*eachSectionCount!+indexPath.row
        
        let cell = self.imageCollectionView?.cellForItem(at: indexPath)
        self.laseImageView = UIImageView(image: image)
        
        //获取cell相对于整个屏幕的位置
        let window = UIApplication.shared.keyWindow
        let rect = cell?.convert((cell?.bounds)!, to: window)
        let showFrame = rect
        
        self.laseImageView?.frame = bgView!.convert(showFrame!, from: self.currentVC?.view)
        bgView!.addSubview(self.laseImageView!)
        
        self.bgView?.backgroundColor = UIColor.black
        UIApplication.shared.keyWindow?.addSubview(bgView!)
        
        self.originalFrame = showFrame!
        
        UIView.animate(withDuration: 0.5, animations: { 
            var frame = self.laseImageView?.frame
            frame?.size.width = self.bgView!.frame.size.width
            frame?.size.height = (frame?.size.width)!*((self.laseImageView?.image?.size.height)!/(self.laseImageView?.image?.size.width)!)
            frame?.origin.x = 0
            frame?.origin.y = (self.bgView!.frame.size.height-(frame?.size.height)!)*0.5
            self.laseImageView?.frame = frame!
        }) { (result) in
            UIApplication.shared.keyWindow?.addSubview(self.showScrollView)
            self.showScrollView.dataSourceArr.removeAll()
            for image in self.imageArray!{
                self.showScrollView.dataSourceArr.append(image)
            }
            self.showScrollView.dataSourceArr.remove(at: (self.imageArray?.count)!-1)
            self.showScrollView.addImagesToScrollView(tag: tag)
            self.showScrollView.isHidden = false
            self.bgView?.isHidden = true
        }
        
    }
    
    //恢复图片大小
    func recoverPicture(tap: UITapGestureRecognizer) {
        self.bgView?.isHidden = false
        showScrollView.isHidden = true
        UIView.animate(withDuration: 0.5, animations: {
            self.laseImageView?.frame = self.originalFrame!
            self.bgView?.backgroundColor = UIColor.clear
        }) { (finisheh) in
            self.laseImageView?.removeFromSuperview()
            self.bgView?.removeFromSuperview()
            self.showScrollView.removeFromSuperview()
        }
    }
    
    //给照片打水印
    func watermarkImage(img: UIImage,titles: [NSString]) -> UIImage {
        
        var resultImage  = img
        var index : CGFloat = 1
        
        var totalHeight : CGFloat = 0.0
        
        for var mark in titles {
            
            var len = 0
            var numbers = [Int]()
            let str : NSMutableString = NSMutableString(string: mark)
            var lastEnd = 0
            while len < mark.length {
                
                //计算需要添加的换行符
                let testStr = str.substring(with: NSMakeRange(lastEnd, len-lastEnd))
                let attr = [NSFontAttributeName:UIFont.systemFont(ofSize: resultImage.size.width/24),
                            NSForegroundColorAttributeName: waterMarkColor] as [String : Any]
                let size = testStr.size(attributes: attr)
                if size.width >= img.size.width - 100{
                    numbers.append(len)
                    lastEnd = len
                }
                len += 1
            }
            
            //在原字符串中插入换行符
            var calculate = 0
            for insertNum in numbers {
                str.insert("\n", at: insertNum+calculate)
                calculate += 1
            }
            
            mark = str as NSString
            UIGraphicsBeginImageContext(resultImage.size)
            resultImage.draw(in: CGRect(x: 0, y: 0, width: resultImage.size.width, height: resultImage.size.height))
            
            let attr = [NSFontAttributeName:UIFont.systemFont(ofSize: resultImage.size.width/24),
                        NSForegroundColorAttributeName: waterMarkColor] as [String : Any]
            let size = mark.size(attributes: attr)
            
            totalHeight += size.height
            mark.draw(in: CGRect(x: 20, y: resultImage.size.height-totalHeight-20*index, width: size.width, height: size.height), withAttributes: attr)
        
            index += 1
            
            resultImage = UIGraphicsGetImageFromCurrentImageContext()!
            
        }
        return resultImage
    }
    
    //获取当前显示的视图控制器
    func getCurrentVC() -> UIViewController {
        let result : UIViewController
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
            result = nextRespnder as! UIViewController
        }else{
            result = (window?.rootViewController)!
        }
        return result
    }
    
}

extension ImageSelectView:UICollectionViewDelegate,UICollectionViewDataSource{
    
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
        cell.deleteView?.tag = indexPath.section*eachSectionCount!+indexPath.row
        cell.deleteView?.isUserInteractionEnabled = true
        let deleteTap = UITapGestureRecognizer(target: self, action: #selector(deleteImage(tap:)))
        cell.deleteView?.addGestureRecognizer(deleteTap)
        
        //添加图片按钮不需要删除图标
        cell.deleteView?.isHidden = (indexPath.section*eachSectionCount! + indexPath.row + 1) == (imageArray?.count)! && hasAddImage
        
        return cell
    }
    
    //选中某个cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (indexPath.section*eachSectionCount! + indexPath.row + 1) == (imageArray?.count)! && hasAddImage {
            
            self.delegate?.willAddImage(selectView: self)
            
            if selectPictureType == SelectType.SELECT_BOTH {
                currentVC?.present(alertVC!, animated: true, completion: nil)
            }else if selectPictureType == SelectType.SELECT_CAMERA{
                self.takePhoto()
            }else{
                self.intoPhotoLibrary()
            }
            
        }else{
            let cell : ImageCollectionCell = collectionView.cellForItem(at: indexPath) as! ImageCollectionCell
            self.previewPicture(image: (cell.imgView?.image)!,indexPath: indexPath)
        }
    }
}

extension ImageSelectView: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.currentVC?.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            if watermarkEnable {
                let markImage = self.watermarkImage(img: image, titles: watermarkArray!)
                imageArray?.insert(markImage, at: (imageArray?.count)!-1)
                self.delegate?.didAddImage(selectView: self, image: markImage)
            }else{
                imageArray?.insert(image, at: (imageArray?.count)!-1)
                self.delegate?.didAddImage(selectView: self, image: image)
            }
        
            //当图片数目达到最大值，删除最后一张添加图片的image
            if imageArray?.count == maxNumber+1 {
                imageArray?.remove(at: ((imageArray?.count)!-1))
                hasAddImage = false
            }
            self.refreshView()
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.currentVC?.dismiss(animated: true, completion: nil)
    }
}

extension ImageSelectView: UIScrollViewDelegate{
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.laseImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.laseImageView?.center = scrollView.center
        var frame = self.laseImageView?.frame
        frame?.origin.x = 0
        self.laseImageView?.frame = frame!
    }
}


