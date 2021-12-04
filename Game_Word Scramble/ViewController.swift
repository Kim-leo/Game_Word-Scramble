//
//  ViewController.swift
//  Game_Word Scramble
//
//  Created by 김승현 on 2021/11/30.
//

import UIKit

class ViewController: UITableViewController {

    var allWords = [String]()   //to hold all the words in the input file
    var usedWords = [String]()  //to hold all the words the player has currently used in the game.
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        /**
         The things that we need to do step by step.
         1. We need to turn that into an array of words we can play with.
         2. We need to load that word list into a string
         3. Then, split it into an array by breaking up wherever we see \n.
         
         Because those line breaks are marked with a special line break character that is usually expressed as \n.
         
         Bundle: 파일시스템에서 파일을 찾게해주는 built-in method.
         
         path(forResource:): This takes as its parameters the name of the file and its path extension,
         and returns a String? ,which means, you either get the path back or nil if it didn't exist.
         
         String:components(seperatedBy:): To split our single string into an array of strings
         based on wherever we find a line break(\n).
         
         try?: "Call this code, and if it throws an error just send me back nil instead."
         This meas the code you call will always work, but you need to unwrap the result carefully.
         */
    
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
        //'.isEmpty' is equal to '.count == 0' but it's faster than using '.count == 0'.
        
        startGame()
    }
    
    func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    /**
     Line2 removes all values from the usedWords array, which we'll be using to store the player's answer so far.
     
     Line3 calls the reloadData() method of tableView.
     */
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] _ in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    /**
     addTextField(): This method just adds an editable text input field to the UIAlertController.
     
     addAction(): This method is used to add a UIAlertAction to a UIAlertController.
     
     UITextField is a editable text box that shows the keyboard so the user can enter something.
     
     weak self, weak ac:
        self -> the current view controller
        ac -> UIAlertController
     we declare them as being weak so that Swift won't create a string reference cycle.
     
     Everything after 'in' is the actual code of the closure.
     
     Inside the closure we need to reference methods on our view controller using self
     so that we're clearly acknowledging the posibility of a strong reference cycle.
     
     
     guard let answer = ac?.textFields?[0].text else { return }
     self?.submit(answer)
     The first lines safely unwraps the array of text fields - it's optional because there might not be array.
     The second line pulls out the text from the text field and passes it to our submit() method.
     */
    
    func submit(_ answer: String) {
        let lowerAnswer = answer.lowercased()
        
        let errorTitle: String
        let errorMessage: String
        
        if isPossible(word: lowerAnswer) {
            if isOriginal(word: lowerAnswer) {
                if isReal(word: lowerAnswer) {
                    usedWords.insert(answer, at: 0)
                    
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    
                    return
                } else {
                    errorTitle = "Word not recognised"
                    errorMessage = "You can't just make them up, you know!"
                }
            } else {
                errorTitle = "Word used already"
                errorMessage = "Be more original!"
            }
        } else {
            guard let title = title?.lowercased() else { return }
            errorTitle = "Word not possible"
            errorMessage = "You can't spell that word from \(title)"
        }
        
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }

    
    func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else { return false }
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        if misspelledRange.location == NSNotFound {
            return true
        } else {
            return false
        }
    }
    /*
     UITextChecker(): This is an iOS class that is designed to spot spelling error,
     which makes it perfect for knowing if a given word is real or not.
     
     NSRange: This is used to sotre a string range, which is a value that holds a start position and a length.
     We want to examine the whole string, so we use 0 for the start position and sthe string's length for the length.
     
     
     */
}

