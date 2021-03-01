//
//  GridStack.swift
//  CalSwiftUI
//
//  Created by Adam Kes on 11/11/19.
//  Copyright © 2019 KesDev. All rights reserved.
/*  Credit: Paul Hudson, https://www.hackingwithswift.com/quick-start/swiftui/how-to-position-views-in-a-grid
 */
import SwiftUI

//@available(OSX 10.15, *)
//@available(iOS 13.0, *)
struct GridStack<Content: View>: View {

    let rows: Int
    let cols: Int
    let content: (Int, Int) -> Content

    var body: some View {

        VStack(spacing:5) {
            ForEach(0..<self.rows) { row in
                HStack(spacing:0) {
                    ForEach(0..<self.cols) { col in
                        //Spacer()
                        self.content(row, col)
                            .frame(width: (UIScreen.main.bounds.width-80)/CGFloat((cols)))
                            //.padding(.top, 5)
                            //.padding(.bottom, 5)
                            //.overlay(Rectangle().stroke())
                        //Spacer()
                    }
                }

            }
        }
    }


    init(rows: Int, columns: Int, @ViewBuilder content: @escaping (Int, Int) -> Content) {
        self.rows = rows
        self.cols = columns
        self.content = content
    }

}

//@available(OSX 10.15, *)
//@available(iOS 13.0, *)
struct GridStack_Previews: PreviewProvider {

    static var previews: some View {
        List{
            HStack {
                Spacer()
                GridStack(rows: 5, columns: 7) { row, col in
                Text("1")
                }
                Spacer()
            }
        }.listStyle(InsetGroupedListStyle())
    }
}
