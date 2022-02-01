import Foundation

struct User {
    let name: String
    let resultString: String
    let guessString: String

    var results: [(String, String)] = []

    init(_ initString: String) {

        let lines = initString.split(separator: "\n")

        let name = "\(lines.first!)"
        let guesses = "\(lines.last!)"

        self.init(name: name, lines.dropFirst().dropLast().joined(separator: "\n"), guesses)
    }

    init(name: String, _ resultString: String, _ guessString: String) {
        self.name = name
        self.resultString = resultString
        self.guessString = guessString.lowercased()

        let resultLines = self.resultString.split(separator: "\n")
        let guessLines = self.guessString.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }

        for i in 0..<resultLines.count {
            results.append( ("\(resultLines[i])", "\(guessLines[i])") )
        }
    }

    fileprivate func handleReduction(_ reduction: Int, _ isGoodGuess: Bool) {
        switch reduction {
        case 2..<10:
            print("Reduction: \(reduction)x - Rank D")
        case 10..<50:
            print("Reduction: \(reduction)x - Rank C")
        case 50..<100:
            print("Reduction: \(reduction)x - Rank B")
        case 100..<150:
            print("Reduction: \(reduction)x - Rank A GREAT!")
        case 150..<Int.max:
            print("Reduction: \(reduction)x - Rank S INCREDIBLE!")
        default:
            break
        }

        if !isGoodGuess {
            print("[b]*** Easy Mode Penalty. Half points. ***[/b]")
        }
    }

    func score(words: [String]) -> Int {
        print("=========== \(name) ===========")

        var score = 0

        var possibleWords = words.sorted()
        var mustNotContain = Set<String>()
        var yellowSquares: [String: [Int]] = [:]
        var greenSquares: [String: Int] = [:]

        var turn = 1

        for (result, word) in results {
            for i in 0..<5 {
                let letter = word[i]
                switch result[i] {
                case "⬛", "⬜":
                    if greenSquares[letter] == nil && yellowSquares[letter] == nil {
                        mustNotContain.insert(letter)
                    }
                case "🟨":
                    if let misses = yellowSquares[letter] {
                        yellowSquares[letter] = misses + [i]
                    } else {
                        yellowSquares[letter] = [i]
                    }
                case "🟩":
                    greenSquares[letter] = i
                    mustNotContain.remove(letter)
                default: break
                }
            }

            let isGoodGuess = possibleWords.contains(word)

            let preFilterCount = possibleWords.count

            possibleWords = possibleWords.filter {

                for mustNotContain in mustNotContain {
                    if $0.contains(mustNotContain) {
                        return false
                    }
                }

                for (letter, indices) in yellowSquares {
                    for index in indices {
                        if $0[index] == letter {
                            return false
                        }
                    }

                    if !$0.contains(letter) {
                        return false
                    }
                }

                for (letter, index) in greenSquares {
                    if $0[index] != letter {
                        return false
                    }
                }

                return true
            }

            let postFilterCount = possibleWords.count

            let reduction = preFilterCount / postFilterCount

            let probability = NSString(format: "%.2f", 100.0 / Double(possibleWords.count))

            if result == "🟩🟩🟩🟩🟩" {
                handleReduction(reduction, isGoodGuess)

                if isGoodGuess {
                    score += reduction
                } else {
                    score += reduction / 2
                }

                let base = (6 - turn) * 100
                score += base

                if turn == 1 {
                    print("scumbag detection enabled")
                    score = -500
                }

                print("#\(turn): 🟩🟩🟩🟩🟩 \(score) points")
            } else {
                print("#\(turn): \(result) [spoiler]\(word)[/spoiler]")

                handleReduction(reduction, isGoodGuess)

                if isGoodGuess {
                    score += reduction
                } else {
                    score += reduction / 2
                }

                if possibleWords.count == 1 {
                    print("The answer has to be [spoiler]\(possibleWords.joined(separator: ", "))[/spoiler]")
                } else if possibleWords.count < 50 {
                    print("\(possibleWords.count) possibilities: [spoiler]\(possibleWords.joined(separator: ", "))[/spoiler]")
                } else {
                    print("\(possibleWords.count) possible answers remain.")
                }

                if possibleWords.count > 1 {
                    print("\(probability)% chance to guess on next turn")
                }

                print("--------------------------------")

                if turn == 6 {
                    score -= 100
                    print("## Wordle failed. \(score) points")
                }
            }

            turn += 1
        }

        print("==================================\n")

        return score
    }
}

func generateUsers(userString: String) -> [User] {
    let lines = userString.split(separator: "\n")

    var buffer: [String] = []
    var users: [User] = []

    for line in lines {
        if line == "." {
            users.append(User(buffer.joined(separator: "\n")))
            buffer = []
        } else {
            buffer.append("\(line)")
        }
    }

    if !buffer.isEmpty {
        users.append(User(buffer.joined(separator: "\n")))
    }

    return users
}

let users: [User] = generateUsers(userString: results)
