import UIKit
import RxSwift
import RxCocoa
import Valet

class LoginViewController: UIViewController {
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var lblError: UILabel!
    @IBOutlet weak var btnLogin: UIButton!
    
    let disposeBag: DisposeBag = DisposeBag()
    let alert : UIAlertController = UIAlertController (
        title: nil,
        message: nil,
        preferredStyle: .alert )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = R.string.main.loginViewTitle()
        self.alert.title = "Login"
        self.alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        btnLogin.rx.tap.subscribe(onNext: {
            [weak self] in
            guard let `self` = self else { return }
            guard let valetIdentifier = Identifier(nonEmpty: R.string.main.valetIdentifier()) else { return }
            
            let valet : Valet = Valet.valet(with: valetIdentifier, accessibility: .whenUnlocked)
            
            if let username = valet.string(forKey: R.string.main.valetUsername()),
                let password = valet.string(forKey: R.string.main.valetPassword()),
                let _usernameTextField = self.userNameTextField.text,
                let _passwordTextField = self.passwordTextField.text
            {
                if username == _usernameTextField && password == _passwordTextField
                {
                    self.alert.message = "DEU BOA -> Manda pra tela de MENU"
                    self.present(self.alert, animated: true)
                }
                else
                {
                    self.alert.message = R.string.main.loginViewMsg()
                    self.present(self.alert, animated: true)
                }
            }
        }).disposed(by: disposeBag)
        
        Observable.combineLatest(userNameTextField.rx.text,
                                 passwordTextField.rx.text) {
                                    username, password -> Bool in
                                    if let _username = username,
                                        let _password = password {
                                        return _username.count >= 0 && _password.count >= 6
                                    }
                                    return false
            }.bind { passed in
                self.btnLogin.isEnabled = passed
            }.disposed(by: disposeBag)
    }
}
