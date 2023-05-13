//
//  ViewExtensions.swift
//  Logbook
//
//  Created by Tan Yun ching on 8/3/22.
//

import Foundation
import UIKit
import SwiftUI

struct OnFirstAppearModifier: ViewModifier {
    let perform:() -> Void
    @State private var firstTime: Bool = true
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                if firstTime {
                    firstTime = false
                    self.perform()
                }
            }
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
            
            ZStack(alignment: alignment) {
                placeholder().opacity(shouldShow ? 1 : 0)
                self
            }
        }
    
    func onFirstAppear(perform: @escaping () -> Void) -> some View {
        return self.modifier(OnFirstAppearModifier(perform: perform))
    }
    
    func alert(isPresented: Binding<Bool>, _ alert: AlertConfig) -> some View {
        AlertHelper(isPresented: isPresented, alert: alert, content: self)
    }
}
