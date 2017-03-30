//
//  ImageCollectionCell.swift
//  TestProject
//
//  Created by 时明 on 2017/3/10.
//  Copyright © 2017年 shiming. All rights reserved.
//

import UIKit
import SnapKit

class ImageCollectionCell: UICollectionViewCell {
    
    var imgView : UIImageView?
    var deleteView : UIImageView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addUI()
        self.doLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addUI(){
        imgView = UIImageView()
        deleteView = UIImageView(image: UIImage(named: "deleteImage"))
        deleteView?.layer.masksToBounds = true
        deleteView?.layer.cornerRadius = (deleteView?.bounds.size.width)!/2
        self.contentView.addSubview(imgView!)
        self.contentView.addSubview(deleteView!)
    }
    
    func doLayout(){
        imgView?.snp.makeConstraints({ (make) in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        })
        deleteView?.snp.makeConstraints({ (make) in
            make.width.equalTo(30)
            make.height.equalTo(30)
            make.leading.equalToSuperview().offset((deleteView?.superview?.bounds.size.width)!-30)
            make.top.equalToSuperview()
        })
    }
}
