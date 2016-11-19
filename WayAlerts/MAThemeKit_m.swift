// The output below is limited by 4 KB.
// Upgrade your plan to remove this limitation.

//
//  MAThemeKit.m
//  MAThemeKit
//
//  Created by Mike on 8/29/14.
//  Copyright (c) 2014 Mike Amaral. All rights reserved.
//
import UIKit

//let kDefaultNavigationBarFontSize: CGFloat = 22

//let kDefaultTabBarFontSize: CGFloat = 14

class MAThemeKit {
    
    let kDefaultNavigationBarFontSize: CGFloat = 22
    
    let kDefaultTabBarFontSize: CGFloat = 14

    
    class func setupThemeWithPrimaryColor(primaryColor: UIColor, secondaryColor: UIColor, fontName: String, lightStatusBar: Bool) {
        if lightStatusBar {
            UIApplication.sharedApplication().statusBarStyle = .LightContent
        }
        self.customizeNavigationBarColor(primaryColor, textColor: secondaryColor, fontName: fontName, fontSize: Constants.Generic.kDefaultNavigationBarFontSize, buttonColor: secondaryColor)
        self.customizeNavigationBarButtonColor(secondaryColor)
  
        self.customizeTabBarColor(primaryColor, textColor: secondaryColor, fontName: fontName, fontSize: Constants.Generic.kDefaultTabBarFontSize)
        
        
        self.customizeSwitchOnColor(primaryColor)
        self.customizeSearchBarColor(primaryColor, buttonTintColor: secondaryColor)
        self.customizeActivityIndicatorColor(primaryColor)
        self.customizeButtonColor(primaryColor)
        self.customizeSegmentedControlWithMainColor(primaryColor, secondaryColor: secondaryColor)
        self.customizeSliderColor(primaryColor)
        self.customizePageControlCurrentPageColor(primaryColor)
        self.customizeToolbarTintColor(primaryColor)
    }
    // MARK: - UINavigationBar
    
    class func customizeNavigationBarColor(barColor: UIColor, textColor: UIColor, buttonColor: UIColor) {
        UINavigationBar.appearance().barTintColor = barColor
        UINavigationBar.appearance().tintColor = buttonColor
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: textColor]
    }
    
    class func customizeNavigationBarColor(barColor: UIColor, textColor: UIColor, fontName: String, fontSize: CGFloat, buttonColor: UIColor) {
        UINavigationBar.appearance().barTintColor = barColor
        UINavigationBar.appearance().tintColor = buttonColor
        var font = UIFont(name: fontName, size: fontSize)
        if (font != nil) {
            UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: textColor, NSFontAttributeName: font!]
        }
    }
    // MARK: - UIBarButtonItem
    
    class func customizeNavigationBarButtonColor(buttonColor: UIColor) {
        
        UIButton.my_appearanceWhenContainedIn(UINavigationBar.self).setTitleColor(buttonColor, forState: .Normal)
        
        //UIButton.appearanceWhenContainedIn(UINavigationBar.self, nil).setTitleColor(buttonColor, forState: .Normal)
    }
    
    //// MARK: - UITabBar
    //
    // func customizeTabBarColor(barColor: UIColor, textColor: UIColor) {
    //    UITabBar.appearance().barTintColor = barColor
    //    UITabBar.appearance().tintColor = textColor
    //}
    //
    // func customizeTabBarColor(barColor: UIColor, textColor: UIColor, fontName: String, fontSize: CGFloat) {
    //    UITabBar.appearance().barTintColor = barColor
    //    UITabBar.appearance().tintColor = textColor
    //    var font = UIFont(name: fontName, size: fontSize)
    //    if (font != nil) {
    //        UITabBarItem.appearance().setTitleTextAttributes([NSFontAttributeName: font!], forState: .Normal)
    //    }
    //}
    //// MARK: - UIButton
    //
    // func customizeButtonColor(buttonColor: UIColor) {
    //    UIButton.appearance().setTitleColor(buttonColor, forState: .Normal)
    //}
    //// MARK: - UISwitch
    //
    // func customizeSwitchOnColor(switchOnColor: UIColor) {
    //    UISwitch.appearance().onTintColor = switchOnColor
    //}
    
    // MARK: - UIActivityIndicator
    
    class func customizeActivityIndicatorColor(color: UIColor) {
        UIActivityIndicatorView.appearance().color = color
    }
    
    // MARK: - UIButton
    
    class func customizeButtonColor(buttonColor: UIColor) {
        UIButton.appearance().setTitleColor(buttonColor, forState: .Normal)
    }
    
    // MARK: - UITabBar
    
//    func customizeTabBarColor(barColor: UIColor, textColor: UIColor) {
//        UITabBar.appearance().barTintColor = barColor
//        UITabBar.appearance().tintColor = textColor
//    }
    
    class func customizeTabBarColor(barColor: UIColor, textColor: UIColor, fontName: String, fontSize: CGFloat) {
        UITabBar.appearance().barTintColor = barColor
        UITabBar.appearance().tintColor = textColor
        var font = UIFont(name: fontName, size: fontSize)
        if (font != nil) {
            UITabBarItem.appearance().setTitleTextAttributes([NSFontAttributeName: font!], forState: .Normal)
        }
    }
    
    
    //    func customizeTabBarColor(barColor: UIColor, textColor: UIColor, fontName: String, fontSize: CGFloat) {
    //        UITabBar.appearance().barTintColor = barColor
    //        UITabBar.appearance().tintColor = textColor
    //        var font = UIFont(name: fontName, size: fontSize)
    //        if (font != nil) {
    //            UITabBarItem.appearance().setTitleTextAttributes([NSFontAttributeName: font!], forState: .Normal)
    //        }
    //    }
    
    // MARK: - UISwitch
    
    class func customizeSwitchOnColor(switchOnColor: UIColor) {
        UISwitch.appearance().onTintColor = switchOnColor
    }
    
    // MARK: - UISegmentedControl
    
    class func customizeSegmentedControlWithMainColor(mainColor: UIColor, secondaryColor: UIColor) {
        UISegmentedControl.appearance().tintColor = mainColor
    }
    // MARK: - UISlider
    
    class func customizeSliderColor(sliderColor: UIColor) {
        UISlider.appearance().minimumTrackTintColor = sliderColor
    }
    // MARK: - UIToolbar
    
    class func customizeToolbarTintColor(tintColor: UIColor) {
        UIToolbar.appearance().tintColor = tintColor
    }
    // MARK: - UIPageControl
    
    class func customizePageControlCurrentPageColor(mainColor: UIColor) {
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.lightGrayColor()
        UIPageControl.appearance().currentPageIndicatorTintColor = mainColor
        UIPageControl.appearance().backgroundColor = UIColor.clearColor()
    }
    
    // MARK: - UISearchBar
    
    class func customizeSearchBarColor(barColor: UIColor, buttonTintColor: UIColor) {
        UISearchBar.appearance().barTintColor = barColor
        UISearchBar.appearance().tintColor = barColor
        UIBarButtonItem.my_appearanceWhenContainedIn(UISearchBar.self).setTitleTextAttributes([NSForegroundColorAttributeName: buttonTintColor], forState: .Normal)
    }
    // MARK: - UIActivityIndicator
    
    // func customizeActivityIndicatorColor(color: UIColor) {
    //    UIActivityIndicatorView.appearance().color = color
    //}
    //// MARK: - UISegmentedControl
    //
    // func customizeSegmentedControlWithMainColor(mainColor: UIColor, secondaryColor: UIColor) {
    //    UISegmentedControl.appearance().tintColor = mainColor
    //}
    //// MARK: - UISlider
    //
    //func customizeSliderColor(sliderColor: UIColor) {
    //    UISlider.appearance().minimumTrackTintColor = sliderColor
    //}
    //// MARK: - UIToolbar
    //
    // func customizeToolbarTintColor(tintColor: UIColor) {
    //    UIToolbar.appearance().tintColor = tintColor
    //}
    //// MARK: - UIPageControl
    //
    // func customizePageControlCurrentPageColor(mainColor: UIColor) {
    //    UIPageControl.appearance().pageIndicatorTintColor = UIColor.lightGrayColor()
    //    UIPageControl.appearance().currentPageIndicatorTintColor = mainColor
    //    UIPageControl.appearance().backgroundColor = UIColor.clearColor()
    //}
    
    
    
    // MARK: - Color utilities
    
//    convenience init(R r: CGFloat, G g: CGFloat, B b: CGFloat) {
//        var red: CGFloat = r / 255.0
//        var green: CGFloat = g / 255.0
//        var blue: CGFloat = b / 255.0
//        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
//    }
//    
//    convenience init(hexString hex: String) {
//        var cString = hex.stringByTrimmingCharactersInSet<NSObject>(NSCharacterSet.whitespaceAndNewlineCharacterSet<NSObject>()).uppercaseString
//        // String should be 6 or 8 characters
//        if cString.characters.count < 6 {
//            return UIColor.grayColor()
//        }
//        // strip 0X if it appears
//        if cString.hasPrefix("0X") {
//            cString = cString.substringFromIndex(cString.startIndex.advancedBy(2))
//        }
//        if cString.characters.count != 6 {
//            return UIColor.grayColor()
//        }
//        // Separate into r, g, b substrings
//        var range: NSRange
//        range.location = 0
//        range.length = 2
//        var rString = cString.substringWithRange(range)
//        range.location = 2
//        var gString = cString.substringWithRange(range)
//        range.location = 4
//        var bString = cString.substringWithRange(range)
//        // Scan values
//        var r: UInt
//        var g: UInt
//        var b: UInt
//        NSScanner(string: rString).scanHexInt(r)
//        NSScanner(string: gString).scanHexInt(g)
//        NSScanner(string: bString).scanHexInt(b)
//        return MAThemeKit(R: Float(r), G: Float(g), B: Float(b))
//    }
    
    
}
