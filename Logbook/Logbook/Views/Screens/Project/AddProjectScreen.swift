//
//  AddProjectView.swift
//  Logbook
//
//  Created by Tan Yun ching on 28/01/2022.
//

import SwiftUI

struct AddProjectView: View {
    @State var projectsVM: ProjectsViewModel = ProjectsViewModel()
    @State var title = ""
    @State var description = ""
    @State var endDate = Date()
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        NavigationView {
            VStack{
                Text("Create a new Project")
                    .font(.title3)
                    .foregroundColor(.white)
                    .bold()
                
                //Title
                VStack(spacing: 0) {
                    Text("Title")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal,25)
                        .padding(.vertical,5)
                    
                    VStack {
                        TextField("Enter your project's title", text: $title)
                            .foregroundColor(.black.opacity(0.8))
                        
                    }
                    .padding()
                    .frame(height: 52)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white, lineWidth: 1)
                            .blendMode(.overlay))
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .shadow(color: .secondary.opacity(0.4), radius: 10, x: 0, y: 10)
                    .padding(.horizontal)
                }
                
                //Description
                VStack{
                    Text("Description")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal,25)
                        .padding(.vertical,5)
                    
                    VStack {
                        TextEditor(text: $description)
                            .foregroundColor(.black.opacity(0.8))
                            .lineLimit(3)
                            .padding(0)
                    }.padding()
                        .frame(maxHeight: .infinity)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white, lineWidth: 1)
                                .blendMode(.overlay))
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .shadow(color: .secondary.opacity(0.4), radius: 10, x: 0, y: 10)
                        .padding(.horizontal)
                    
                    
                }
                
                //Date Picker
                HStack {
                    Text("End Date")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding(.horizontal, 25)
                    Spacer()
                    DatePicker("", selection: $endDate, in: Date()..., displayedComponents: .date)
                        .labelsHidden()
                        .colorMultiply(colorScheme == .dark ? .black : .white)
                        .colorInvert()
                        .padding(25)
                }
                
                //Add Project Button
                VStack {
                    Button(action: {
                        projectsVM.addProject(description: description, title: title, endDate: endDate, onAdded: {_ in
                            dismiss()
                        })
                    }, label: {
                        AddBar(fieldText: "Add Project")
                    })
                }
                Spacer()
            }
            .padding(.top, 40)
            .background(BackgroundImage())
            .navigationBarHidden(true)
        }
        
    }
}
