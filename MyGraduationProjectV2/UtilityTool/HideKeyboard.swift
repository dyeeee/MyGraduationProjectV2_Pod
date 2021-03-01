//
//  HideKeyboard.swift
//  MyGraduationProjectV1
//
//  Created by YES on 2021/1/12.
//

import SwiftUI

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
//在View中使用 self.hideKeyboard() 来隐藏键盘


