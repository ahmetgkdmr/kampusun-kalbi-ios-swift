
import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class FikirEkleVC: UIViewController {
    
    
    @IBOutlet weak var sgmntKategoriler: UISegmentedControl!
    
    
    @IBOutlet weak var txtKullaniciAdi: UITextField!
    
    
    @IBOutlet weak var txtFikir: UITextView!
    
    @IBOutlet weak var btnPaylas: UIButton!
    
    let placeholderText = "Fikrinizi Belirtin.."
    
    var secilenKategori = Kategoriler.Dersler.rawValue // Kullanıcı seçmezse default değer olarak kalsın.
    
    var kullaniciAdi : String = "Misafir"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        btnPaylas.layer.cornerRadius = 5 // Köşelerini yuvarlak yapmamızı sağladı.
        txtFikir.layer.cornerRadius = 7
        
        txtFikir.text = placeholderText
        txtFikir.textColor = .lightGray
        txtFikir.delegate = self // yetkilendirme için kullanılan yapı (delegate)
        
        txtKullaniciAdi.isEnabled = false
        
        if let adi = Auth.auth().currentUser?.displayName {
            // Kullanıcı adi firebaseden gelsin ve değiştiremeyelim.
            kullaniciAdi = adi
            txtKullaniciAdi.text = kullaniciAdi
            
        }
        
        
    }

    
    @IBAction func sgmntKategoriDegisti(_ sender: Any) {
        // Kategoriler kısmında seçilen kategoriye göre secilenKategoriye atama yaptık.
        switch sgmntKategoriler.selectedSegmentIndex {
            
        case 0 :
            secilenKategori = Kategoriler.Dersler.rawValue
        case 1 :
            secilenKategori = Kategoriler.Etkinlikler.rawValue
        case 2 :
            secilenKategori = Kategoriler.Kampus.rawValue
        default :
            secilenKategori = Kategoriler.Dersler.rawValue
            
        }
        
    }
    
    
    
    @IBAction func btnPaylasPressed(_ sender: Any) {
        
        guard txtFikir.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty != true else {return}
        // triming ile sadece boş karakter girerse paylaşamaz.
        // FireStoreda bulunan Fikirler (Fikirler_REF) koleksiyonuna paylaşa tıkladığında ilgili dataları kaydediyoruz.
        // Hata varsa hatayı dönüyor.
        
        Firestore.firestore().collection(Fikirler_REF).addDocument(data: [
        
            KATEGORI : secilenKategori,
            Begeni_Sayisi : 0,
            Yorum_Sayisi : 0,
            Fikir_Text : txtFikir.text!,
            Eklenme_Tarihi : FieldValue.serverTimestamp(), // Eklediğimiz sunucunun eklediğimizdeki tarihi
            Kullanici_Adi : kullaniciAdi,
            KULLANICI_ID : Auth.auth().currentUser?.uid ?? ""
            
        ]) { (hata) in
            
            if let hata = hata {
                print("Document Hatası: \(hata.localizedDescription)")
            } else {
                self.navigationController?.popViewController(animated: true) // hata yoksa önceki sayfaya döner. 
            }
        }
        
    }
    
}

extension FikirEkleVC : UITextViewDelegate {
    
    //Kullanıcı bastığında
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.text == placeholderText {
            // Fikrinizi belirtin yazısı duruyorsa ilk yazışıdır. Texti temizliyoruz.Yazmaya başlayabilsin.
            textView.text = ""
            textView.textColor = .darkGray
            
        }
        
    }
    
    // Kullanıcının basması bittiğinde
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.text.isEmpty {
            // Hiç bir şey girmediyse fikrinizi belirtin kalsın.
            txtFikir.text = placeholderText
            txtFikir.textColor = .lightGray
            
        }
    }
}
