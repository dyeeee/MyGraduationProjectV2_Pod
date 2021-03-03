//
//  foriPadTools.swift
//  MyGraduationProjectV2
//
//  Created by YES on 2021/2/8.
//

import Foundation
import UIKit
import SwiftUI

enum Device {
    //MARK:当前设备类型 iphone ipad mac
    enum Devicetype{
        case iPhone,iPad,mac
    }

    static var deviceType:Devicetype{
        #if os(macOS)
        return .mac
        #else
        if  UIDevice.current.userInterfaceIdiom == .pad {
            return .iPad
        }
        else {
            return .iPhone
        }
        #endif
 }
}

extension View {
    @ViewBuilder func ifIs<T>(_ condition: Bool, transform: (Self) -> T) -> some View where T: View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    @ViewBuilder func ifElse<T:View,V:View>( _ condition:Bool,isTransform:(Self) -> T,elseTransform:(Self) -> V) -> some View {
        if condition {
            isTransform(self)
        } else {
            elseTransform(self)
        }
    }
}
