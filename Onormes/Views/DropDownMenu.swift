//
//  DropDownMenu.swift
//  Onormes
//
//  Created by gonzalo on 05/09/2022.
//

import Foundation
import SwiftUI

struct DropDownMenuLabel: Identifiable {
    var name: String;
    var id = UUID();
}

struct DropDownMenu: View {
    
    var _labelList: [DropDownMenuLabel];
    var selectedValue: Binding<String>;
    
    //
    //@State private var selectedValue: String;
    @State private var isShowing = false

    // text is the variable to be bound to
    init(labelList: [String], text: Binding<String>) {
        selectedValue = text
        //print(labelList)
        
        //selectedValue.wrappedValue = labelList[0]

        _labelList = []
        // fill labelList with unique number
        for val in labelList {
            _labelList.append(DropDownMenuLabel(name: val))
        }
    }
    
    var body: some View {
        HStack {
            Spacer()
            Button(selectedValue.wrappedValue) {
                isShowing = !isShowing
            }
            Spacer()
            Image(systemName: "checkmark.circle")
        }.frame(height: 50)
        if isShowing {
            ScrollView {
                List {
                    ForEach(_labelList) { label in
                        HStack {
                            Spacer()
                            Button(label.name) {
                                selectedValue.wrappedValue = label.name
                                isShowing = !isShowing
                            }
                            Spacer()
                            if selectedValue.wrappedValue == label.name {
                                Image(systemName: "checkmark.circle")
                            }
                        }.frame(height: 50)
                        Divider()
                    }
                }
            }.frame(height: 200).background(Color.white)
        }
    }
}

//struct DropDownMenu_Previews: PreviewProvider {
//  static var previews: some View {
//        DropDownMenu(labelList: ["Yaourt", "fromage", "chaussure", "4", "8", "9", "10", "11", "13", "664"])
//  }
//}
