//
//  HomeViewController.swift
//  Testing AR
//
//  Created by Leo Harnadi on 22/05/23.
//

import UIKit
import CoreHaptics

class HomeViewController: UIViewController, MainViewControllerDelegate {
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var scoreTitle: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var highScoreTitle: UILabel!
    @IBOutlet weak var highScoreLabel: UILabel!
    @IBOutlet weak var titleBackground: UILabel!
    @IBOutlet weak var titleFront: UILabel!
    
    var titleText: String = "Squatty \nBird"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let retrievedHighScore = UserDefaults.standard.integer(forKey: "squattyBirdHighScore")
        
        highScore = retrievedHighScore
        
        
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor(named: "lightBlue")
        startButton.setTitle("                            ", for: .normal)
        
        scoreTitle.text = ""
        scoreLabel.text = ""
        highScoreTitle.text = "High Score"
        highScoreLabel.text = String(highScore)
        scoreTitle.font = UIFont(name: foregroundFont, size: 30)
        scoreLabel.font = UIFont(name: foregroundFont, size: 40)
        highScoreTitle.font = UIFont(name: foregroundFont, size: 30)
        highScoreLabel.font = UIFont(name: foregroundFont, size: 40)
        
        titleBackground.font = UIFont(name: backgroundFont, size: 75)
        titleBackground.text = titleText
        titleBackground.textColor = UIColor(named: "darkGreen")
        titleFront.font = UIFont(name: foregroundFont, size: 75)
        titleFront.text = titleText
        titleFront.textColor = UIColor(named: "lightGreen")
        
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
        } catch let error {
            print("Failed to start the haptic engine: \(error)")
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        audioPlayer.playMenu()
    }
    
    @IBAction func startButtonDidPressed(_ sender: Any) {
        scoreTitle.text = "Score"
        scoreLabel.text = "0"
        highScoreTitle.text = "High Score"
        highScoreTitle.textColor = UIColor.black
        
        triggerHapticFeedback(with: createHapticPattern(isLose: false))
        pushToMain()
    }
    
    func pushToMain() {
        //        navigationController?.pushViewController(GameOverViewController(), animated: false)
        let mainViewController = MainViewController()
        mainViewController.delegate = self
        
        navigationController?.pushViewController(mainViewController, animated: false)
    }
    
    func mainViewControllerDidUpdateScore(score: Int, highScore: Int) {
        scoreLabel.text = "\(score)"
        highScoreLabel.text = "\(highScore)"
        
        if score == highScore {
            highScoreTitle.textColor = UIColor.red
            highScoreTitle.text = "NEW High Score"
        }
    }
    
    @objc func appDidEnterBackground() {
        hapticEngine?.stop(completionHandler: { error in
            if let error = error {
                print("Error stopping haptic engine: \(error)")
            }
        })
    }
    
    @objc func appWillEnterForeground() {
        do {
            try hapticEngine?.start()
        } catch {
            print("Error starting haptic engine: \(error)")
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
