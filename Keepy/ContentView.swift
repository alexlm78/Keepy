//
//  ContentView.swift
//  Keepy
//
//  Created by Alejandro Lopez Monzon on 5/11/25.
//

import SwiftUI
import AppKit

struct ContentView: View {
    @State private var noteText: String = ""
    @State private var clipboardText: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Clipboard Text:")
                .font(.headline)
            Text(clipboardText)
                .padding()
                .border(Color.gray)
            
            Divider()
            
            Text("Quick Note")
                .font(.headline)
            TextEditor(text: $noteText)
                .border(Color.gray)
            
            HStack {
                Button("Update Clipboard") {
                    clipboardText = getClipboardContent()
                }
                Spacer()
                Button("Save Note") {
                    saveTemporaryNote()
                }
            }
            .padding(.top)
        }
        .padding()
        .frame(width: 380, height: 280)
        .onAppear {
            clipboardText = getClipboardContent()
        }
    }
    
    func getClipboardContent() -> String {
        let pasteboard = NSPasteboard.general
        if let copiedString = pasteboard.string(forType: .string) {
            return copiedString
        }
        return "Clipboard is empty or it's just empty"
    }
    
    func saveTemporaryNote() {
        let fileManager = FileManager.default
        let tempDir = fileManager.temporaryDirectory
        let noteURL = tempDir.appendingPathComponent("NotaRapida.txt")
        do {
            try noteText.write(to: noteURL, atomically: true, encoding: .utf8)
            print("Quick Note save at: \(noteURL.path)")
        } catch {
            print("Error al guardar la nota rápida: \(error)")
        }
    }
}

//#Preview {
//    ContentView()
//}
