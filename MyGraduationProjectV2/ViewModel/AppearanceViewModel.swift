//
//  AppearanceViewModel.swift
//  MyGraduationProjectV2
//
//  Created by YES on 2021/2/2.
//

import Foundation
import SwiftUI

class AppearanceViewModel: ObservableObject {
    @Published var colorScheme:ColorScheme = getStoredScheme()
    @AppStorage("UD_storedColorScheme") var UD_storedColorScheme = ""
}


func getStoredScheme() -> ColorScheme{
    let UD_storedColorScheme = UserDefaults.standard.string(forKey: "UD_storedColorScheme")
    //let currentSystemScheme = UITraitCollection.current.userInterfaceStyle
    
    switch UD_storedColorScheme {
    case "auto":
        return schemeTransform(userInterfaceStyle: UITraitCollection.current.userInterfaceStyle)
    case "dark":
        return .dark
    case "light":
        return .light
    default:
        return schemeTransform(userInterfaceStyle: UITraitCollection.current.userInterfaceStyle)
    }
}


func schemeTransform(userInterfaceStyle:UIUserInterfaceStyle) -> ColorScheme {
    if userInterfaceStyle == .light {
        return .light
    }else if userInterfaceStyle == .dark {
        return .dark
    }
    return .light
}
