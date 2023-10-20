import UIKit

class AnimationVC: UIViewController {
    
    @IBOutlet weak var notesImageView: UIImageView!
    @IBOutlet weak var notesTextImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notesImageView.alpha = 0.0
        notesTextImageView.alpha = 0.0
        animationStart()
    }
    
    func animationStart() {
        UIView.animate(withDuration: 2.0, animations: {
            self.notesImageView.alpha = 1.0
            self.notesTextImageView.alpha = 1.0
            
        }) { [] (finished) in
            UIView.animate(withDuration: 1.0, animations: {
                self.notesImageView.alpha = 0.0
                self.notesTextImageView.alpha = 0.0
            }) { [] (finished) in
                self.performSegue(withIdentifier: "toViewController", sender: nil)
            }
        }
    }
}
