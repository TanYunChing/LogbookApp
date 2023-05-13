//
//  DeletableImage.swift
//  Logbook
//
//  Created by Tan Yun ching on 6/3/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct ImageItemView: View {
    
    var image: UIImage?
    var url: URL?
    var action: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            if let url = url {
                WebImage(url: url)
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .cornerRadius(4)
                    .shadow(radius: 4)
            } else if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .cornerRadius(4)
                    .shadow(radius: 4)
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

struct DeletableImage_Previews: PreviewProvider {
    static var previews: some View {
        ImageItemView(image: UIImage(), action: {})
    }
}
