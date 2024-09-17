import SwiftUI
import TagsUI


struct ContentView: View {
    @State private var tags: [Tag] = []
    @State private var selectedTag: Tag?
    @State private var tagSearch: String = ""
    @FocusState private var isTokenFieldFocused: Bool
    
    var body: some View {
        VStack {
            TokenField(selection: $selectedTag, searchText: $tagSearch, onDelete: {
                deleteSelected()
            }, label: {
                Text("#")
            }, content: {
                ForEach(tags) { tag in
                    TokenView(token: tag)
                        .font(fontForToken(tag.name))
                        .fontWeight(tag == selectedTag ? .bold : .regular)
                        .onTapGesture {
                            selectedTag = tag
                        }
                }
            })
            .autocorrectionDisabled()
            .textInputAutocapitalization(.words)
            .focused($isTokenFieldFocused)
        }
        .padding()
        .onChange(of: tagSearch) {
            handleInputText()
        }
        .onChange(of: isTokenFieldFocused) { oldValue, newValue in
            if oldValue && !newValue {
                handleInputText(flush: true)
            }
        }
    }
    
    private func handleInputText(flush: Bool = false) {
        if flush {
            let text = tagSearch
            let parts = text.split(separator: " ")
            for value in parts {
                if !value.isEmpty {
                    let tag = Tag(name: String(value))
                    tags.append(tag)
                }
            }
            tagSearch = ""
            return
        }
        
        while tagSearch.contains(" ") {
            let parts = tagSearch.split(separator: " ", maxSplits: 1)
            if let value = parts.first {
                if !value.isEmpty {
                    let tag = Tag(name: String(value))
                    tags.append(tag)
                }
            }
            if parts.count > 1 {
                tagSearch = parts.last.map { String($0) } ?? ""
            }
            else {
                tagSearch = ""
            }
        }
    }
    
    private func deleteSelected() {
        if let tag = selectedTag {
            tags = tags.filter { $0 != tag }
        }
        selectedTag = nil
    }
    
    private struct TokenView: View {
        
        let token: Tag
        
        var body: some View {
            Text(token.name)
        }
    }
}


private func fontForToken(_ text: String) -> Font {
    let n = max(8, min(48, 36 - 20 * log10(CGFloat(text.count))))
    return Font.system(size: n)
}


struct Tag: Hashable, Identifiable {
    var name: String
    var id: String { name }
}


#Preview {
    ContentView()
}
