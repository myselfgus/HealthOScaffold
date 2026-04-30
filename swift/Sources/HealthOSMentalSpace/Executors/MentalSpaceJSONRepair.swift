import Foundation

// Shared JSON extraction and repair utility for MSR executors.
// Mirrors the 3-strategy repair logic from the validated TypeScript scripts
// (4-asl.ts, 5-vdlp.ts, 6-gem.ts) that were validated against 400 patients.
enum MentalSpaceJSONRepair {
    struct ParseError: Error {
        let reason: String
    }

    // Strips markdown fences, extracts the top-level JSON object by brace depth,
    // and applies up to 3 repair strategies before failing.
    static func parse(_ response: String) throws -> [String: Any] {
        var text = response.trimmingCharacters(in: .whitespacesAndNewlines)
        text = text.replacingOccurrences(of: "```json", with: "")
                   .replacingOccurrences(of: "```", with: "")

        guard let jsonStr = extractTopLevelJSON(text) else {
            throw ParseError(reason: "No JSON object found in response")
        }

        // Strategy 0: direct parse
        if let obj = tryParseDict(jsonStr) { return obj }

        // Strategy 1: remove parenthetical annotations — "text" (comment) -> "text"
        let s1 = removeParentheticalAnnotations(jsonStr)
        if let obj = tryParseDict(s1) { return obj }

        // Strategy 2: remove trailing commas
        let s2 = removeTrailingCommas(jsonStr)
        if let obj = tryParseDict(s2) { return obj }

        // Strategy 3: both repairs combined
        let s3 = removeTrailingCommas(s1)
        if let obj = tryParseDict(s3) { return obj }

        throw ParseError(reason: "JSON parse failed after all repair attempts")
    }

    // Brace depth counting — matches the approach in the validated TS scripts.
    // Does not skip string contents (same deliberate simplification as the TS).
    private static func extractTopLevelJSON(_ text: String) -> String? {
        guard let startIdx = text.firstIndex(of: "{") else { return nil }
        var depth = 0
        for idx in text[startIdx...].indices {
            switch text[idx] {
            case "{": depth += 1
            case "}":
                depth -= 1
                if depth == 0 { return String(text[startIdx...idx]) }
            default: break
            }
        }
        return nil
    }

    private static func tryParseDict(_ s: String) -> [String: Any]? {
        guard let data = s.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
        return obj
    }

    private static func removeParentheticalAnnotations(_ s: String) -> String {
        guard let regex = try? NSRegularExpression(pattern: #""([^"]*?)"\s*\([^)]+\)"#) else { return s }
        return regex.stringByReplacingMatches(in: s,
                                              range: NSRange(s.startIndex..., in: s),
                                              withTemplate: #""$1""#)
    }

    private static func removeTrailingCommas(_ s: String) -> String {
        guard let regex = try? NSRegularExpression(pattern: #",(\s*[}\]])"#) else { return s }
        return regex.stringByReplacingMatches(in: s,
                                              range: NSRange(s.startIndex..., in: s),
                                              withTemplate: "$1")
    }
}
