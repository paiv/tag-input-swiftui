import SwiftUI


public struct TokenField<Token, Label, Content>: View where Token:Hashable, Label:View, Content:View {

    @Binding private var selection: Token?
    @Binding private var searchText: String
    private let placeholder: String?
    private let labelBuilder: () -> Label
    private let contentBuilder: () -> Content
    private let onDelete: () -> Void
    @FocusState private var isTextFocused: Bool

    public init(
        selection: Binding<Token?>,
        searchText: Binding<String>,
        searchPlaceholder: String? = nil,
        onDelete: @escaping () -> Void = {},
        @ViewBuilder label: @escaping () -> Label = { EmptyView() },
        @ViewBuilder content: @escaping () -> Content = { EmptyView() }
    ) {
        self._selection = selection
        self._searchText = searchText
        self.placeholder = searchPlaceholder
        self.labelBuilder = label
        self.contentBuilder = content
        self.onDelete = onDelete
    }
    
    public var body: some View {
        HFlow(alignment: .firstTextBaseline) {
            if Label.self != EmptyView.self {
                labelBuilder()
            }
            
            if Content.self != EmptyView.self {
                contentBuilder()
            }
            
            DetectorTextField(
                "Token",
                text: $searchText,
                prompt: placeholder.map { Text($0) },
                acceptEdits: selection == nil,
                onDelete: onDelete
            )
            .frame(minWidth: 100)
            .layoutPriority(-1)
            .tint(selection == nil ? nil : .clear) // nil resets to app's accentColor, not to parent tint
            .focused($isTextFocused)
            .onTapGesture {
                selection = nil
            }
        }
        .onChange(of: searchText) { oldValue, newValue in
            if !newValue.isEmpty {
                selection = nil
            }
        }
        .onAppear {
            isTextFocused = true
        }
    }
    
    
    private struct DetectorTextField: View {
        
        @Binding private var text: String
        @State private var editingText: String
        private let titleKey: LocalizedStringKey
        private let prompt: Text?
        private let acceptEdits: Bool
        private let onDelete: () -> Void
        private let detector = Character("\u{200B}")
        
        init(_ titleKey: LocalizedStringKey, text: Binding<String>, prompt: Text? = nil, acceptEdits: Bool, onDelete: @escaping () -> Void) {
            self.titleKey = titleKey
            self.prompt = prompt
            self.acceptEdits = acceptEdits
            self.onDelete = onDelete
            self._text = text
            self.editingText = String(detector) + text.wrappedValue
        }
        
        var body: some View {
            TextField(
                titleKey,
                text: $editingText,
                prompt: prompt
            )
            .onChange(of: editingText) { oldValue, newValue in
                handleEdit(oldValue, newValue)
            }
            .onChange(of: text) { oldValue, newValue in
                updateFromBinding(newValue)
            }
        }

        private func handleEdit(_ oldValue: String, _ newValue: String) {
            if !acceptEdits, newValue.count < oldValue.count {
                editingText = oldValue
                onDelete()
                return
            }
            let prefix = newValue.prefix { $0 == detector }
            if prefix.isEmpty {
                editingText = String(detector) + newValue
                if newValue.isEmpty {
                    onDelete()
                }
            }
            else {
                let newValue = String(newValue[prefix.endIndex...])
                text = newValue
                if prefix.count > 1 {
                    editingText = String(detector) + newValue
                }
            }
        }
        
        private func updateFromBinding(_ value: String) {
            let prefix = value.prefix { $0 == detector }
            if prefix.count > 0 {
                let value = String(value[prefix.endIndex...])
                editingText = String(detector) + value
            }
            else {
                editingText = String(detector) + value
            }
        }
    }
}


#Preview {
    struct Item: Identifiable, Hashable, CustomStringConvertible {
        var id: String
        var description: String
    }
    
    struct Preview: View {
        @State var items: [Item] = [
            Item(id: "a", description: "Aaa"),
            Item(id: "b", description: "Bbb"),
            Item(id: "c", description: "Ccc"),
        ]
        @State var selection: Item?
        @State var searchText: String = ""
        
        var body: some View {
            TokenField(selection: $selection, searchText: $searchText, searchPlaceholder: "Search", label: {
                Text("label")
            }) {
                ForEach(items) { item in
                    Text(item.description)
                        .fontWeight(item == selection ? .bold : .regular)
                        .onTapGesture {
                            selection = item
                        }
                }
            }
        }
    }
    
    return Preview()
}
