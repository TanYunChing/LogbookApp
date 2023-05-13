//
//  LogItemView.swift
//  Logbook
//
//  Created by Tan Yun ching on 7/3/22.
//

import SwiftUI
import PDFKit

struct FileItemView: View {
    var action: () -> Void
    var document : URL
    @State private var showPDF = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            HStack(alignment: .center) {
                Image(systemName: "doc.text")
                Text(document.lastPathComponent)
                    .font(.caption)
                    .bold()
                    .lineLimit(1)
            }
            .padding([.top, .bottom, .leading], 6)
            .padding(.trailing, 12)
            .background(.blue.opacity(0.1))
            .cornerRadius(4)
            .onTapGesture {
                showPDF = true
            }
            .sheet(isPresented: $showPDF) {
                PdfView(document: document)
            }
            Button(action: action) {
                HStack {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 6, height: 6)
                        .padding([.all], 6)
                        .foregroundColor(.white)
                        .background(.red)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
            }.offset(x: 6, y: -6)
        }
    }
}

struct PdfView : UIViewRepresentable {
    var document : URL
    
    func makeUIView(context: UIViewRepresentableContext<PdfView>) -> PDFView {
        
        let path = document
        let document = PDFDocument(url: path)
        let pdfView = PDFView()
        pdfView.document = document
        pdfView.scaleFactor = 1
        pdfView.autoScales = true
        
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: UIViewRepresentableContext<PdfView>) {
        
    }
}
