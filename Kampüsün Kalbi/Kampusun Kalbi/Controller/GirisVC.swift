
import UIKit
import FirebaseAuth

class GirisVC: UIViewController {

    
    @IBOutlet weak var txtEmailAdresi: UITextField!
    
    
    @IBOutlet weak var txtParola: UITextField!
    
    @IBOutlet weak var btnGirisYap: UIButton!
    
    
    @IBOutlet weak var btnHesapOlustur: UIButton!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("girisVC yüklendi")
        btnGirisYap.layer.cornerRadius = 10 // butonların kenarlarının yuvarlak olmasını sağlıyor
        btnHesapOlustur.layer.cornerRadius = 10
        
    }

    @IBAction func btnGirisYapPressed(_ sender: Any) {
        
        guard let emailAdresi = txtEmailAdresi.text,
        let parola = txtParola.text else {return}
        
        print("Giriş yapa tıklandı")
        
        Auth.auth().signIn(withEmail: emailAdresi, password: parola){ (kullanici,hata) in
            
            if let hata = hata {
                
                debugPrint("Oturum açarken hata meydana geldi \(hata.localizedDescription)")
            } else {
                
                self.dismiss(animated: true, completion: nil)
            }
        }
        
    }
    
}
