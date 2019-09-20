//
//  WiseTextView.swift
//  WiseTextView-Demo
//
//  Created by frank on 2019/9/19.
//  Copyright © 2019 frank. All rights reserved.
//

import UIKit

let kScreenWidth = UIScreen.main.bounds.width
let kScreenHeight = UIScreen.main.bounds.height

//用屏幕比例进行适配
func kUIFitSize(size : CGFloat) -> CGFloat {
    return size * kScreenWidth / 375.0
}
func kRGBColorFromHex(rgbValue: Int, alpha: CGFloat) -> UIColor {
    return UIColor(red: ((CGFloat)((rgbValue & 0xFF0000) >> 16)) / 255.0,
                   green:((CGFloat)((rgbValue & 0xFF00) >> 8)) / 255.0,
                   blue: ((CGFloat)(rgbValue & 0xFF)) / 255.0, alpha: alpha)
}
func kRGBColorFromHex(rgbValue: Int) -> UIColor {
    return UIColor(red: ((CGFloat)((rgbValue & 0xFF0000) >> 16)) / 255.0,
                   green:((CGFloat)((rgbValue & 0xFF00) >> 8)) / 255.0,
                   blue: ((CGFloat)(rgbValue & 0xFF)) / 255.0, alpha: 1.0)
}
func kStatusBarHeight() -> CGFloat {
    return UIApplication.shared.statusBarFrame.size.height
}
func kNavigationBarHeight() -> CGFloat {//导航栏+状态栏高度
    return kStatusBarHeight() + 44
}
func IS_iPhoneX_Screen() -> Bool {
    return (kStatusBarHeight() > 20 && kStatusBarHeight() != 40) //区分调用系统功能的头部蓝色提示
}
func kSafeAreaBottomSpace() -> CGFloat {
    return IS_iPhoneX_Screen() ? 20 : 0
}

class WiseTextView: UIView {
    private var cursorMinSpace = CGFloat(0) //光标高于键盘的最小距离
    private let minHeightTxt: CGFloat = CGFloat(96) //输入框最小高度
    private var currentTxtH: CGFloat = CGFloat(96) //记录当前输入框的高度
    private var keyboardHeight: CGFloat = 0 //记录键盘的高度
    
    var subTextView: KMPlaceholderTextView? //文本内容输入视图
    
    var textValueChangedBlock: ((_ str: String)->(Void))? //文本内容改变回调
    var textBecomeFirstRespnderClouse: (() -> ())? //成为第一响应者
    var updateTxtHeightClouse: ((_ height: CGFloat) -> ())? //更新文本视图高度回调
    

    init(frame: CGRect, cursorSpace: CGFloat) {
        super.init(frame: frame)
        
        self.cursorMinSpace = cursorSpace
        subTextView = KMPlaceholderTextView(frame: CGRect(x: 0, y: 0, width: self.width, height: self.height))
        subTextView?.backgroundColor = UIColor.clear
        subTextView?.font = UIFont.systemFont(ofSize: kUIFitSize(size: 16))
        subTextView?.textColor = kRGBColorFromHex(rgbValue: 0x333333)
        subTextView?.textContainer.lineFragmentPadding = 0 //内容缩进为0（去除左右边距）
        subTextView?.textContainerInset = .zero //文本边距设为0（去除上下边距）
        subTextView?.layer.borderColor = kRGBColorFromHex(rgbValue: 0x777777).cgColor
        subTextView?.layer.borderWidth = 0.5
        subTextView?.delegate = self
        subTextView?.placeholder = "分享此刻新鲜事..."
        subTextView?.returnKeyType = .done
        subTextView?.isScrollEnabled = false
        subTextView?.layoutManager.allowsNonContiguousLayout = false //是否非连续布局属性,设置为 NO 后 UITextView 就不会再自己重置滑动了。
        self.addSubview(subTextView!)
        subTextView?.translatesAutoresizingMaskIntoConstraints = false //
        let contraint1 = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tf]-0-|", options: .alignAllLeft, metrics: nil, views: ["tf": subTextView!])
        let contraint2 = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[tf]-0-|", options: .alignAllTop, metrics: nil, views: ["tf": subTextView!])
        self.addConstraints(contraint1)
        self.addConstraints(contraint2)
        
        self.frame = CGRect(x: self.left, y: self.y, width: self.width, height: subTextView!.bottom)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardChange(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
        
    }
    
    //MARK: -------KeyBoard Notification Handlers-------
    @objc private func keyboardChange(notification: NSNotification) {
        let userInfo = notification.userInfo
//        let animationDuration = (userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
//        let animationCurve = (userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue
        let keyboardEndFrame = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        keyboardHeight = keyboardEndFrame?.height ?? 0

    }
    
    deinit {
        debugPrint(#function + #file)
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: -------根据光标位置调整父视图的滚动-------
    @objc private func updateSuperViewOffset() {
        if keyboardHeight <= 0 {
            return
        }
        let superViewScroll = self.superview as? UIScrollView
        //拿到光标在屏幕中的位置
        let caretRect = self.subTextView?.caretRect(for: self.subTextView!.selectedTextRange!.end) ?? .zero
        // 将获取到的光标frame转化到屏幕中去
        let rectInWindow = self.subTextView?.convert(caretRect, to: superViewScroll) ?? .zero
        if rectInWindow == .zero || rectInWindow == CGRect.null {
            return
        }
        let keyboardY: CGFloat = kScreenHeight - keyboardHeight - kNavigationBarHeight()
        if keyboardY - (rectInWindow.maxY + cursorMinSpace) < 0  {
            UIView.performWithoutAnimation {
                superViewScroll?.contentOffset.y = (rectInWindow.maxY + cursorMinSpace) - keyboardY
            }
        }
    }
}

extension KMPlaceholderTextView {//在光标位置添加内容
    func textWithString(nstr: String) {
        // 1.1 获取当前输入的文字
        let string = self.text
        // 1.2 获取光标位置
        var rg = self.selectedRange
        if rg.location == NSNotFound {
            // 如果没找到光标,就把光标定位到文字结尾
            rg.location = NSString(string: self.text).length
        }
        // 1.3 替换选中文字
        self.text = (string as? NSMutableString)?.replacingCharacters(in: rg, with: nstr)
        // 1.4 定位光标
        self.selectedRange = NSMakeRange(rg.location + nstr.count, 0)
    }
}

extension WiseTextView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textBecomeFirstRespnderClouse?() //
        self.perform(#selector(textViewDidChange(_:)), with: textView, afterDelay: 0.1)
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        let superViewScroll = self.superview as? UIScrollView
        superViewScroll?.superview?.endEditing(true) //
    }
    //内容发生改变编辑
    func textViewDidChange(_ textView: UITextView) {
        
        textValueChangedBlock?(textView.text)
        
        
        let newHeight = CGFloat(ceil(Double(textView.sizeThatFits(CGSize(width: kScreenWidth-kUIFitSize(size: 32), height: CGFloat.greatestFiniteMagnitude)).height)))
        
        if currentTxtH != newHeight {
            
            UIView.setAnimationsEnabled(false)
            if newHeight < minHeightTxt {
                currentTxtH = minHeightTxt
                
            } else {
                currentTxtH = newHeight
                
            }
            self.height = subTextView!.frame.maxY
            self.updateTxtHeightClouse?(subTextView!.top + kUIFitSize(size: 10) + currentTxtH) //
            
            UIView.setAnimationsEnabled(true)
            
        }
        
        self.perform(#selector(updateSuperViewOffset), with: textView, afterDelay: 0.2)
    }
    
    //焦点发生改变
    func textViewDidChangeSelection(_ textView: UITextView) {
        textValueChangedBlock?(textView.text)
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == " " {
            return false
        }

        return true
    }
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {

        return true
    }
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return true
    }
}
