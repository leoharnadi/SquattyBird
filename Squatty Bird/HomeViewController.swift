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
    @IBOutlet weak var birdSprite: UIImageView!
    
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
        
        titleBackground.text = titleText
        titleBackground.textColor = UIColor(named: "darkGreen")
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let viewHeight = view.frame.height
        let viewWidth = view.frame.height
        let viewTopAnchor = view.topAnchor
        let viewBottomAnchor = view.bottomAnchor
        let viewCenterXAnchor = view.centerXAnchor
        
        scoreTitle.font = UIFont(name: foregroundFont, size: 30 * (viewHeight/844))
        scoreLabel.font = UIFont(name: foregroundFont, size: 40 * (viewHeight/844))
        highScoreTitle.font = UIFont(name: foregroundFont, size: 30 * (viewHeight/844))
        highScoreLabel.font = UIFont(name: foregroundFont, size: 40 * (viewHeight/844))
        
        titleBackground.font = UIFont(name: backgroundFont, size: 75 * (viewHeight/844))
        titleFront.font = UIFont(name: foregroundFont, size: 75 * (viewHeight/844))
        
        startButton.translatesAutoresizingMaskIntoConstraints = false
        titleBackground.translatesAutoresizingMaskIntoConstraints = false
        titleFront.translatesAutoresizingMaskIntoConstraints = false
        scoreTitle.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        highScoreTitle.translatesAutoresizingMaskIntoConstraints = false
        highScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        birdSprite.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([startButton.bottomAnchor.constraint(equalTo: viewBottomAnchor, constant: -0.05 * viewHeight),
                                     startButton.centerXAnchor.constraint(equalTo: viewCenterXAnchor), startButton.widthAnchor.constraint(equalToConstant: 0.46 * viewWidth), startButton.heightAnchor.constraint(equalToConstant: 0.22 * viewHeight),
                                     
                                     titleBackground.topAnchor.constraint(equalTo: viewTopAnchor, constant: 0.108 * viewHeight),
                                     titleBackground.centerXAnchor.constraint(equalTo: viewCenterXAnchor), titleBackground.widthAnchor.constraint(equalToConstant: viewWidth),titleBackground.heightAnchor.constraint(equalToConstant: 0.12 * viewHeight),
                                     
                                     titleFront.topAnchor.constraint(equalTo: viewTopAnchor, constant: 0.108 * viewHeight),
                                     titleFront.centerXAnchor.constraint(equalTo: viewCenterXAnchor), titleFront.widthAnchor.constraint(equalToConstant: viewWidth),titleFront.heightAnchor.constraint(equalToConstant: 0.12 * viewHeight),
                                     
                                     highScoreTitle.topAnchor.constraint(equalTo: viewTopAnchor, constant: 0.236 * viewHeight), highScoreTitle.centerXAnchor.constraint(equalTo: viewCenterXAnchor), highScoreTitle.widthAnchor.constraint(equalToConstant: 0.641 * viewWidth), highScoreTitle.heightAnchor.constraint(equalToConstant: 0.06 * viewHeight),
                                     
                                     highScoreLabel.topAnchor.constraint(equalTo: viewTopAnchor, constant: 0.271 * viewHeight), highScoreLabel.centerXAnchor.constraint(equalTo: viewCenterXAnchor), highScoreLabel.widthAnchor.constraint(equalToConstant: 0.384 * viewWidth), highScoreLabel.heightAnchor.constraint(equalToConstant: 0.047 * viewHeight),
                                     
                                     scoreTitle.topAnchor.constraint(equalTo: viewTopAnchor, constant: 0.319 * viewHeight), scoreTitle.centerXAnchor.constraint(equalTo: viewCenterXAnchor), scoreTitle.widthAnchor.constraint(equalToConstant: 0.384 * viewWidth), scoreTitle.heightAnchor.constraint(equalToConstant: 0.047 * viewHeight),
                                     
                                     scoreLabel.topAnchor.constraint(equalTo: viewTopAnchor, constant: 0.354 * viewHeight), scoreLabel.centerXAnchor.constraint(equalTo: viewCenterXAnchor), scoreLabel.widthAnchor.constraint(equalToConstant: 0.384 * viewWidth), scoreLabel.heightAnchor.constraint(equalToConstant: 0.047 * viewHeight),
                                     
                                     birdSprite.topAnchor.constraint(equalTo: viewTopAnchor, constant: 0.436 * viewHeight), birdSprite.centerXAnchor.constraint(equalTo: viewCenterXAnchor), birdSprite.widthAnchor.constraint(equalToConstant: 0.615 * viewWidth), birdSprite.heightAnchor.constraint(equalToConstant: 0.296 * viewHeight),
                                    ])
        //        print(startButton.frame)
        //        view.layoutIfNeeded()
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
