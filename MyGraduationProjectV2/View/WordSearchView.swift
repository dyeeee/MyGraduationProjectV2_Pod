//
//  WordSearchView.swift
//  MyGraduationProjectV1
//
//  Created by YES on 2021/1/13.
//

import SwiftUI

struct WordSearchView: View {
    @StateObject var wordVM: WordViewModel
    @State private var searchText = ""
    
    var body: some View {
        NavigationView{
            VStack {
                WordListView(wordVM: self.wordVM,dataType: .searchResult)
                
            }.listStyle(InsetGroupedListStyle())
            .navigationBarTitle(Text("查询单词"), displayMode: .inline)
            .showTabBar()
            .toolbar { // <2>
                ToolbarItem(placement: .navigationBarLeading) { // <3>
                    Button {
                        self.wordVM.deleteAll()
                    } label: {
                        Text("DeleteAll")
                    }
                    
                }
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
                            Label("Preload", systemImage: "text.badge.plus")
                        }
                        Button(action: {
                            self.wordVM.preloadFromBigCSV()
                        }) {
                            Label("Preload Big", systemImage: "text.badge.plus")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            
        }
        
        //.navigationViewStyle(DoubleColumnNavigationViewStyle())
    }
}


struct WordSearchView_Previews: PreviewProvider {
    static var previews: some View {
        return WordSearchView(wordVM: WordViewModel())
    }
}
