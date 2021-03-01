//
//  HomeTabView.swift
//  MyGraduationProjectV1
//
//  Created by YES on 2020/12/27.
//

import SwiftUI

struct HomeTabView: View {
    @State var selectedTab: TabSelection = .page1
    @StateObject var wordVM = WordViewModel()

    @StateObject var dayContentVM:DayContentViewModel = DayContentViewModel()
    @StateObject var todoVM = ToDoViewModel()
    @StateObject var appearanceVM:AppearanceViewModel = AppearanceViewModel()
    @StateObject var userVM = UserViewModel()
    
    init() {
        UITabBar.appearance().barTintColor = UIColor.systemGroupedBackground
    }
    
    var body: some View {
        TabView(selection: $selectedTab){
//            HomeView(dayContentViewModel: self.dayContentViewModel)
            HomeView(dayContentVM: self.dayContentVM, todoVM: self.todoVM, selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "cube.fill")
                    Text("摘要")
                }
                .tag(TabSelection.page1)
            
            LearnStartView(dayContentVM:self.dayContentVM)
//            Text("p2")
                .navigationTitle(Text("page2"))
                .tabItem {
                    Image(systemName: "graduationcap.fill")
                    Text("学习")
                }
                .tag(TabSelection.page2)
            
            NotebookListView(wordVM: self.wordVM)
            //Text("p3")
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("生词本")
                }
                .tag(TabSelection.page3)
            
            WordSearchView(wordVM: self.wordVM)
            //Text("p4")
                .tabItem {
                    Image(systemName: "character.book.closed.fill")
                    Text("词典")
                }
                .tag(TabSelection.page4)
            
//            ShowAllWordsView(wordListViewModel: wordListViewModel)
            //LearningWordListVIew()
            SettingView(appearanceVM: self.appearanceVM, userVM: self.userVM, wordVM: self.wordVM)
                .onAppear(perform: {
                    //勉强解决自动切换的问题
                    self.appearanceVM.colorScheme = getStoredScheme()
                    print("----解决自动切换深色模式的onAppear----")
                })
                .tabItem {
                    Image(systemName: "gearshape.2.fill")
                    Text("设置")
                }
                .tag(TabSelection.page5)
        }
        .preferredColorScheme(self.appearanceVM.colorScheme)
        //.accentColor(.red)
        //.navigationBarColor(.systemGroupedBackground)
    }
}


enum TabSelection {
    case page1
    case page2
    case page3
    case page4
    case page5
}

struct HomeTabView_Previews: PreviewProvider {
    static var previews: some View {
        HomeTabView()
    }
}
