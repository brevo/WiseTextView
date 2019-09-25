# WiseTextView
Constrain the minimum distance of the cursor from the keyboard（约束光标距离键盘的最小距离）

![image](https://github.com/brevo/WiseTextView/blob/master/WiseTextView-Demo/WiseTextView-Demo/resource/show1.gif?raw=true)

Usage
-----

- **Import several filesk**:The file in the folder whose name is "WiseTextView"
ps: If your project is of type Swift, you need to configure the bridge file, because the OC type of UIView is used in the project.

    ```objc
    #import "UIView+Frame.h"
    ```
However, if your project is created with OC, you need to configure the pre-compiled file with .pch as the suffix in addition to the bridge file.You only need to copy the contents of objc-Demo-Prefix.pch to your precompiled file.



Then create `WiseTextView` and set `cursorSpace`.

- **Implement Objective-C**

    ```objc
    WiseTextView *inputView = [[WiseTextView alloc] initWithFrame:CGRectMake(kUIFitSize(16), kUIFitSize(10), kUIScreenWidth - kUIFitSize(32), kUIFitSize(100)) cursorSpace:20];
    ```
- **Implement Swift**:

    ```swift
    et inputView = WiseTextView(frame: CGRect(x: kUIFitSize(size: 16), y: kUIFitSize(size: 10), width: kScreenWidth - kUIFitSize(size: 32), height: kUIFitSize(size: 100)), cursorSpace: CGFloat(20))
    ```
    
Congratulations! You're done. 🎉


License
-------

UITextView+Placeholder is under MIT license. See the [LICENSE](LICENSE) file for more information.
