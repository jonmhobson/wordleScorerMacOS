import Foundation

extension String {
    subscript(i: Int) -> String {
        return String(self[index(startIndex, offsetBy: i)])
    }
}

let answers = "wordle-answers-alphabetical"
let allowed = "wordle-allowed-guesses"

do {
    let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    let bundleURL = URL(fileURLWithPath: "Files.bundle", relativeTo: currentDirectoryURL)
    let bundle = Bundle(url: bundleURL)
    let answersPath = bundle!.url(forResource: answers, withExtension: "txt")!
    let allowedPath = bundle!.url(forResource: answers, withExtension: "txt")!
    let answers = try String(contentsOfFile: answersPath.path, encoding: .utf8)
    let allowed = try String(contentsOfFile: allowedPath.path, encoding: .utf8)
    let words: [String] =
    answers.split(separator: "\n").map { "\($0)" } +
    allowed.split(separator: "\n").map { "\($0)" }

    var scoreboard: [(String, Int)] = []

    for user in users {
        let score = user.score(words: words)
        scoreboard.append((user.name, score))
    }

    var rank = 1

    print("-----==== LEADERBOARD ====-----")

    for score in scoreboard.sorted(by: { $0.1 > $1.1 }) {
        print("\(rank). \(score.0) - \(score.1) points")
        rank += 1
    }

    print("-------------------------------")

} catch let error as NSError {
    print("Ooops! Something went wrong: \(error)")
}
