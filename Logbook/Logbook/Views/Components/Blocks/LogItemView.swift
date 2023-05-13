//
//  LogItemView.swift
//  Logbook
//
//  Created by Tan Yun ching on 23/03/2022.
//

import SwiftUI

struct LogItemView: View {
    @State var block: BlockModel
    let version: Version
    var action: () -> Void
    var onUpdateBlock: (BlockModel) -> Void
    
    @State private var selectedLog: Log? = nil
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            HStack(alignment: .center) {
                Image(systemName: "square.grid.2x2")
                Text(block.logBlock?.title ?? "")
                    .font(.caption)
                    .bold()
                    .lineLimit(1)
                Spacer()
                Image(systemName: "chevron.down")
            }
            .frame(maxWidth:.infinity)
            .padding([.top, .bottom, .leading], 6)
            .padding(.trailing, 12)
            .background(.blue.opacity(0.1))
            .cornerRadius(4)
            .onTapGesture {
                selectedLog = block.logBlock
            }
            .sheet(item: $selectedLog, onDismiss: {
                selectedLog = nil
            }, content: { log in
                SubLogSheet(block: block, version: version, onSave: { log in
                    block.logBlock = log
                    onUpdateBlock(block)
                })
            })
            
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

