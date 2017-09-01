
import UIKit

class FirstViewController: UIViewController {

    @IBAction func searchButtonTaped(_ sender: Any) {
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        appDelegate.transitionView()
        let newViewController = BluetoothViewController()
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
    }
}
