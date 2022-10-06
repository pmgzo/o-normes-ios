//
//  ResearchBar.swift
//  Onormes
//
//  Created by gonzalo on 06/10/2022.
//

import Foundation
import SwiftUI

struct ResearchBar: View {
    private var _text: Binding<String>;

    init(text: Binding<String>) {
        _text = text
    }
    
    var body: some View {
        HStack {
            Spacer()
            Image(systemName: "magnifyingglass")
                .frame(width: 10, height: 10)
            Spacer()
            TextField("", text: _text)
        }
        .overlay(RoundedRectangle(cornerRadius: 20)
            .stroke(.gray, lineWidth: 0.5))
        .frame(width: 300, height: 50)
    }
}
