//
//  ViewController.swift
//  WiseTextView-Demo
//
//  Created by frank on 2019/9/19.
//  Copyright © 2019 frank. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        let bgScrollView = UIScrollView()
        view.addSubview(bgScrollView)
        bgScrollView.delegate = self
        bgScrollView.translatesAutoresizingMaskIntoConstraints = false
        bgScrollView.contentSize = CGSize(width: kScreenWidth, height: kScreenHeight*CGFloat(1.5))

        let contraint1 = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[bg]-0-|", options: .alignAllLeft, metrics: nil, views: ["bg": bgScrollView])
        let contriant2 = NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(kNavigationBarHeight())-[bg]-\(kSafeAreaBottomSpace()+kUIFitSize(size: 10))-|", options: .alignAllTop, metrics: nil, views: ["bg": bgScrollView])
        view.addConstraints(contraint1)
        view.addConstraints(contriant2)
        
        let inputView = WiseTextView(frame: CGRect(x: kUIFitSize(size: 16), y: kUIFitSize(size: 10), width: kScreenWidth - kUIFitSize(size: 32), height: kUIFitSize(size: 100)), cursorSpace: CGFloat(20))
        bgScrollView.addSubview(inputView)
        inputView.font = UIFont.systemFont(ofSize: kUIFitSize(size: 16))
        inputView.textColor = kRGBColorFromHex(rgbValue: 0x333333)
        inputView.layer.borderColor = kRGBColorFromHex(rgbValue: 0x777777).cgColor
        inputView.layer.borderWidth = 0.5
        inputView.placeholder = "分享此刻新鲜事..."
        inputView.returnKeyType = .done
        //文本输入框成为第一响应者
        inputView.textBecomeFirstRespnderClouse = {
            
        }
        //输入内容变化
        inputView.textValueChangedBlock = {valueStr in
//            debugPrint(valueStr)
        }
        inputView.updateTxtHeightClouse = {[weak self] currentH in
//            debugPrint(currentH)
            inputView.height = currentH
            if inputView.bottom != bgScrollView.contentSize.height {
                if inputView.bottom <= (self?.view.height ?? 0) {
                    
                } else {
                    bgScrollView.contentSize.height = inputView.bottom
                }
            }
        }
    }


}

extension ViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}

