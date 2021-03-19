//
//  WordSearchView.swift
//  MyGraduationProjectV1
//
//  Created by YES on 2021/1/13.
//

import SwiftUI
import UIKit

struct WordSearchView: View {
    @StateObject var wordVM: WordViewModel
    @State private var searchText = ""
    //@Binding var orientation:  UIDeviceOrientation
    @State var orientation = UIDevice.current.orientation
    
    var body: some View {
        NavigationView{
            VStack {
                WordListView(wordVM: self.wordVM,dataType: .searchResult)
                
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitle(Text("查询单词"), displayMode: .inline)
            .showTabBar()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu{
                        Button(action: {
                            self.wordVM.createTestItem()
                        }) {
                            Label("Create Test", systemImage: "plus.circle")
                        }
                        Button(action: {
                            self.wordVM.preloadFromCSV()
                        }) {
                            Label("Preload", systemImage: "homepod.fill")
                        }
                        Button(action: {
                            self.wordVM.preloadFromBigCSV()
                        }) {
                            Label("Preload Big", systemImage: "homepod.2.fill")
                        }
                        Button {
                            self.wordVM.deleteAll()
                        } label: {
                            Label("deleteAll", systemImage: "trash.fill")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            // iPad横屏双列状态的默认显示界面
            Text("test")
            
        }
        //更改方向
        .onReceive(NotificationCenter.Publisher(center: .default, name: UIDevice.orientationDidChangeNotification)) { _ in
            if UIDevice.current.orientation != UIDeviceOrientation(rawValue: 5){
                self.orientation = UIDevice.current.orientation
            }
        }
        .onAppear(perform: {
            if UIDevice.current.orientation != UIDeviceOrientation(rawValue: 0){
                orientation = UIDevice.current.orientation
            }
            //print(orientation.rawValue)
        })
        .ifIs(Device.deviceType == .iPhone){
            $0.navigationViewStyle(StackNavigationViewStyle())
        }
        .ifIs(Device.deviceType == .iPad && (orientation.isPortrait)){
            $0.navigationViewStyle(StackNavigationViewStyle())
        }
        .ifIs(Device.deviceType == .iPad && (orientation.isLandscape)){
            $0.navigationViewStyle(DoubleColumnNavigationViewStyle())
        }
        
    }
}


struct WordSearchView_Previews: PreviewProvider {
    static var previews: some View {
        return WordSearchView(wordVM: WordViewModel())
    }
}
