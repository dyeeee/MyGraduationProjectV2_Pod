//
//  DeviceAdaptation.swift
//  MyGraduationProjectV2
//
//  Created by YES on 2021/3/19.
//

import Foundation
import UIKit
import SwiftUI

enum Device {
    //MARK:当前设备类型 iPhone iPad Mac
    enum Devicetype{
        case iPhone,iPad,Mac
    }
    static var deviceType:Devicetype{
        #if targetEnvironment(macCatalyst)
            return .Mac
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

//用法
//VStack{
//     Text("hello world")
//}
//.ifIs(Deivce.deviceType == .iphone){
//  $0.frame(width:150)
//}
//.ifIs(Device.deviceType == .ipad){
//  $0.frame(width:300)
//}
//.ifIs(Device.deviceType == .mac){
//  $0.frmae(minWidth:200,maxWidth:600)
//}
