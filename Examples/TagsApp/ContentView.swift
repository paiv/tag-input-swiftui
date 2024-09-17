import SwiftUI
import TagsUI


struct ContentView: View {
    
    var body: some View {
        List {
            TagPanel("sky fades bright stars gleam winds hum and dusk falls still") { tag in
                TokenView1(token: tag)
            }
            TagPanel("a list of plain tokens of equal font size") { tag in
                TokenView2(token: tag)
            }
        }
        .listStyle(.plain)
    }
}


struct TagPanel<TagView>: View where TagView:View {
    private let tokenView: (Tag) -> TagView
    @State private var tags: [Tag] = []
    @State private var selectedTag: Tag?
    @State private var tagSearch: String = ""
    @FocusState private var isTokenFieldFocused: Bool

    init(_ text: String, @ViewBuilder tokenView: @escaping (Tag) -> TagView = { _ in EmptyView() }) {
        self.tokenView = tokenView
        self._tags = State(initialValue: text.split(separator: " ").map { Tag(name: String($0)) })
    }
    
    var body: some View {
        VStack {
            TokenField(selection: $selectedTag, searchText: $tagSearch, onDelete: {
                deleteSelected()
            }, label: {
                Text("#")
            }, content: {
                ForEach(tags) { tag in
                    tokenView(tag)
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
}


private struct TokenView1: View {
    let token: Tag
    
    var body: some View {
        Text(token.name)
            .font(TokenView1.fontForToken(token.name))
            .padding(4)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .stroke()
            )
    }
    
    private static func fontForToken(_ text: String) -> Font {
        let n = max(8, min(48, 36 - 20 * log10(CGFloat(text.count))))
        return Font.system(size: n)
    }
}


private struct TokenView2: View {
    let token: Tag
    
    var body: some View {
        Text(token.name)
            .foregroundStyle(Color.white)
            .padding(4)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.purple)
            )
    }
}


struct Tag: Hashable, Identifiable {
    var name: String
    var id: String { name }
}


#Preview {
    ContentView()
}
