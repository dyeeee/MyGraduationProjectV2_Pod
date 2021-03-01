//
//  DarkModeSettingView.swift
//  MyGraduationProjectV2
//
//  Created by YES on 2021/2/1.
//

import SwiftUI
import  UIKit

struct DarkModeSettingView: View {
//    @Environment(\.colorScheme) var systemColorScheme
    // 问题在于这个变量记录的不是手机系统的外观，而是当前app的外观。
    // 如果手动改成light，这个也会是light
    //改成UIKit
    var systemColorScheme: UIUserInterfaceStyle = UITraitCollection.current.userInterfaceStyle

    
    @StateObject var appearanceVM:AppearanceViewModel
    
    var body: some View {
            List {
                VStack {
                    Button(action: {
                        self.appearanceVM.UD_storedColorScheme = "light"
                        self.appearanceVM.colorScheme = getStoredScheme()
                    }, label: {
                        HStack {
                            Image(systemName: "sun.max.fill")
                            Text("保持浅色模式")
                            Spacer()
                            Image(systemName: "arrow.left")
                                .foregroundColor(self.appearanceVM.UD_storedColorScheme == "light" ? Color(.systemBlue) : Color.clear)
                        }.foregroundColor(self.appearanceVM.UD_storedColorScheme == "light" ? Color(.systemBlue) : Color(.systemGray))
                    })
                    
                }
                VStack {
                    Button(action: {
                        self.appearanceVM.UD_storedColorScheme = "dark"
                        self.appearanceVM.colorScheme = getStoredScheme()
                    }, label: {
                        HStack {
                            Image(systemName: "moon.zzz.fill")
                            Text("保持深色模式")
                            Spacer()
                            Image(systemName: "arrow.left")
                                .foregroundColor(self.appearanceVM.UD_storedColorScheme == "dark" ? Color(.systemBlue) : Color.clear)
                        }.foregroundColor(self.appearanceVM.UD_storedColorScheme == "dark" ? Color(.systemBlue) : Color(.systemGray))
                    })
                   
                }
                Section{
                VStack {
                    Button(action: {
                        self.appearanceVM.UD_storedColorScheme = "auto"
                        self.appearanceVM.colorScheme = getStoredScheme()
                    }, label: {
                        HStack {
                            Image(systemName: "iphone")
                            Text("跟随系统自动切换")
                            Spacer()
                            Image(systemName: "arrow.left")
                                .foregroundColor(self.appearanceVM.UD_storedColorScheme == "auto" ? Color(.systemBlue) : Color.clear)
                        }.foregroundColor(self.appearanceVM.UD_storedColorScheme == "auto" ? Color(.systemBlue) : Color(.systemGray))
                    })
                }
                           
                }
                Section{
                    HStack {
                        Text("当前手机系统外观:")
                        Text(systemColorScheme == .dark ? "深色模式" : "浅色模式")
                    }
                    .foregroundColor(Color(.systemGray2))
                    .font(.callout)
                    Button(action: {
                        self.appearanceVM.colorScheme = getStoredScheme()
                    }, label: {
                        Text("Refresh")
                    })
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitle("深色模式设置")
            .navigationBarTitleDisplayMode(.inline)
            //.preferredColorScheme(setColorScheme)
            
    }
}

struct DarkModeSettingView_Previews: PreviewProvider {
    static var previews: some View {
        DarkModeSettingView(appearanceVM: AppearanceViewModel())
    }
}


