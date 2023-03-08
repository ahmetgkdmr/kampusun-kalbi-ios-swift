
import UIKit
import Firebase
import FirebaseAuth

class KullaniciOlusturVC: UIViewController {

    
    @IBOutlet weak var txtEmailAdresi: UITextField!
    @IBOutlet weak var txtParola: UITextField!
    @IBOutlet weak var txtKullaniciAdi: UITextField!
    @IBOutlet weak var btnHesapOlustur: UIButton!
    @IBOutlet weak var btnVazgectim: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnVazgectim.layer.cornerRadius = 10
        btnHesapOlustur.layer.cornerRadius = 10
        
        
    }
    
    
    @IBAction func btnHesapOlusturPressed(_ sender: Any) {
        
        guard let emailAdresi = txtEmailAdresi.text,
        let parola = txtParola.text,
        let kullaniciAdi = txtKullaniciAdi.text else {return}
        
        Auth.auth().createUser(withEmail: emailAdresi, password: parola){
            (kullaniciBilgileri , hata) in
            
            if let hata = hata {
                debugPrint("Kullanıcı Oluştururken Hata Meydana Geldi \(hata.localizedDescription)")
            }
            // Hata meydana gelmedi o zaman kullanıcı başarılı bir şekilde oluşturuldu.
            
            let changeRequest = kullaniciBilgileri?.user.createProfileChangeRequest()
            changeRequest?.displayName = kullaniciAdi // oluşturduğumuz kullanıcının username ini atadık.
            changeRequest?.commitChanges(completion: { (hata) in
                
                if let hata = hata {
                    
                    debugPrint("Kullanıcı adı güncellenirken hata meydana geldi \(hata.localizedDescription)")
                }
            })
            
            guard let kullaniciId = kullaniciBilgileri?.user.uid else {return}
            
            // Kullanıcılar collectionına kullanıcıId ile document ekler.
            Firestore.firestore().collection(KULLANICILAR_REF).document(kullaniciId).setData([
                KULLANICI_ADI : kullaniciAdi,
                KULLANICI_OLUSTURMA_TARIHI : FieldValue.serverTimestamp()
            ], completion :{ (hata) in
                
                if let hata = hata {
                    
                    debugPrint("Kullanıcı eklenirken hata meydana geldi \(hata.localizedDescription)")
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
                
            })
            
        }
        
    }
    
    
    @IBAction func btnVazgectimPressed(_ sender: Any) {
        
        dismiss(animated: true, completion: nil) // önceki sayfaya geri döner.
        
    }
    
}
