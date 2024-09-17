import Foundation


extension String {
    
    static func random(count: Int) -> String {
        String((0..<count).map { _ in abc.randomElement()! })
    }
    
    static func randomWord(count: Int) -> String {
        (0..<count/2).map { _ in l2.randomElement()! }.joined()
        + (count.isMultiple(of: 2) ? "" : String(abc.randomElement()!))
    }
    
    static func random(wordCount: Int) -> String {
        (0..<wordCount).map { _ in randomWord(count: Int.random(in: 2..<10))}
            .joined(separator: " ")
    }

    private static let abc = Array("abcdefghijklmnopqrstuvwxyz")
    private static let l2 = [
        "th", "he", "an", "in", "er", "nd", "re", "ed", "es", "ou", "to", "ha",
        "en", "ea", "st", "nt", "on", "at", "hi", "as", "it", "ng", "is", "or",
        "et", "of", "ti", "ar", "te", "se", "me", "sa", "ne", "wa", "ve", "le",
        "no", "ta", "al", "de", "ot", "so", "dt", "ll", "tt", "el", "ro", "ad",
        "di", "ew", "ra", "ri", "sh",
    ]
}
