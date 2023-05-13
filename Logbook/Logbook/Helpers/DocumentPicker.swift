//
//  DocumentPicker.swift
//  Logbook
//
//  Created by Tan Yun ching on 09/03/2022.
//

import SwiftUI
import MobileCoreServices
import UniformTypeIdentifiers

struct DocumentPicker : UIViewControllerRepresentable {
    @Binding var document : URL?
    
    
    func makeCoordinator() -> Coordinator {
        return DocumentPicker.Coordinator(parent: self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentPicker>) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController.init(forOpeningContentTypes: [UTType.pdf])
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<DocumentPicker>) {}
    
    class Coordinator : NSObject, UIDocumentPickerDelegate {
        
        var parent : DocumentPicker
        
        init(parent : DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else {return}
            parent.document = url
            print("Document saved")
        }
        
    }
    
}
