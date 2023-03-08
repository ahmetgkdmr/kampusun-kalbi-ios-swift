
import UIKit
import Firebase
import FirebaseAuth

class YorumlarVC: UIViewController {

    var secilenFikir : Fikir!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var txtYorum: UITextField!
    
    var yorumlar = [Yorum]()
    
    var fikirRef : DocumentReference!
    var fireStore = Firestore.firestore()
    var kullaniciAdi : String!
    
    var yorumlarListener : ListenerRegistration!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        // seçili olan fikrin documentId sini alıyoruz.
        fikirRef = fireStore.collection(Fikirler_REF).document(secilenFikir.documentId )
        
        if let adi = Auth.auth().currentUser?.displayName{
            
            kullaniciAdi = adi
        }
        self.view.klavyeAyarla() // klavye açıldığında view ı y ekseninde yukarı kaydırdık.
    }

    // sayfa gözüktükten sonra yorumları çekiyoruz. listener anlık güncelleme olması için kullanılan yapıdır.
    override func viewDidAppear(_ animated: Bool) {
        
        yorumlarListener = fireStore.collection(Fikirler_REF).document(secilenFikir.documentId).collection(YORUMLAR_REF)
            .order(by: Eklenme_Tarihi, descending: false)
            .addSnapshotListener({ (snapshot, hata) in
                
                guard let snapshot = snapshot else {
                    
                    debugPrint("Yorumları getirirken hata meydana geldi : \(hata?.localizedDescription)")
                    return
                    
                }
                
                self.yorumlar.removeAll() // yorumlar çoklamasın diye silip tekrar çekiyoruz.
                self.yorumlar = Yorum.yorumlariGetir(snapshot: snapshot)
                self.tableView.reloadData()
                
            })
        
    }
    
    
    
    @IBAction func btnYorumEkleTapped(_ sender: Any) {
        
        guard let yorumText = txtYorum.text, txtYorum.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty != true else {return} // triming ile öğrenci sadece boş karakter girip yorum atamaz.
        
        
        /* Transaction yapısını hem documentId ye bağlı yorumlar kısmını hem de yorumsayisi kısmını aynı anda güncellemek istediğimiz için kullandık. İnternet yokken transaction yapısı kullanılamaz. Bellekte cache e atmaz. */
        fireStore.runTransaction({ (transection, errorPointer) -> Any? in
            
            let secilenFikirKayit : DocumentSnapshot
            do{
                
                try secilenFikirKayit = transection.getDocument(self.fireStore.collection(Fikirler_REF).document(self.secilenFikir.documentId))
                
            }
            catch let hata as NSError {
                
                debugPrint("Hata Meydana Geldi: \(hata.localizedDescription)")
                return nil
                
            }
            
            
            guard let eskiYorumSayisi = (secilenFikirKayit.data()?[Yorum_Sayisi] as? Int) else {return nil}
            
            transection.updateData([Yorum_Sayisi : eskiYorumSayisi+1], forDocument: self.fikirRef)
            
            let yeniYorumRef = self.fireStore.collection(Fikirler_REF).document(self.secilenFikir.documentId).collection(YORUMLAR_REF).document()
            
            transection.setData([
                YORUM_TEXT : yorumText,
                Eklenme_Tarihi : FieldValue.serverTimestamp(),
                Kullanici_Adi : self.kullaniciAdi,
                KULLANICI_ID : Auth.auth().currentUser?.uid ?? ""
            
            ], forDocument: yeniYorumRef)
            
            
            return nil
            
        }) { (nesne, hata) in
            
            if let hata = hata {
                
                debugPrint("Hata Meydana Geldi Transaction: \(hata.localizedDescription)")
                
            } else {
                
                self.txtYorum.text = ""
                
            }
            
            
        }
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "YorumDuzenleSegue" {
            
            if let hedefVC = segue.destination as? YorumDuzenleVC {
                
                if let yorumVeri = sender as? (secilenYorum: Yorum, secilenFikir : Fikir) {
                    
                    hedefVC.yorumVerisi = yorumVeri
                    
                }
                
            }
            
        }
        
    }
    
}

extension YorumlarVC : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return yorumlar.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "YorumCell", for: indexPath) as? YorumCell {
            
            cell.gorunumAyarla(yorum: yorumlar[indexPath.row],delegate: self) // hücrede her biri gözükmesi için
            return cell
            
        }
        
        return UITableViewCell()
        
    }
    
    
}

extension YorumlarVC : YorumDelegate {
    func seceneklerYorumPressed(yorum: Yorum) {
        
        let alert = UIAlertController(title: "Yorumu Düzenle", message: "Yorumunuzu düzenleyebilir veya silebilirsiniz", preferredStyle: .actionSheet)
        let silAction = UIAlertAction(title: "Yorumu Sil", style: .default)  { (action) in
            
            
            /* Transaction yapısını hem documentId ye bağlı yorumlar kısmını hem de yorumsayisi kısmını aynı anda güncellemek istediğimiz için kullandık. İnternet yokken transaction yapısı kullanılamaz. Bellekte cache e atmaz. */
            self.fireStore.runTransaction({ (transaction, hata) -> Any? in
                
                // önce okuma sonra güncelleme silmeyi yaptık. Her zaman böyle olmalıdır. Çünkü orjinal veriyi ilk okumalıyız.
                let secilenFikirKayit : DocumentSnapshot
                do {
                    try secilenFikirKayit =
                    transaction.getDocument(self.fireStore.collection(Fikirler_REF).document(self.secilenFikir.documentId))
                    
                } catch let hata as NSError {
                    debugPrint("Fikir Bulunamadı : \(hata.localizedDescription)")
                    return nil
                }
                
                guard let eskiYorumSayisi = (secilenFikirKayit.data()?[Yorum_Sayisi] as? Int) else {return nil}
                transaction.updateData([Yorum_Sayisi : eskiYorumSayisi-1], forDocument: self.fikirRef)
                
                let silincekYorumRef = self.fireStore.collection(Fikirler_REF).document(self.secilenFikir.documentId).collection(YORUMLAR_REF).document(yorum.documentId)
                transaction.deleteDocument(silincekYorumRef)
                return nil
            }) { (nesne,hata) in
                
                if let hata = hata {
                    debugPrint("Yorum silerken hata meydana geldi : \(hata.localizedDescription)")
                } else {
                    alert.dismiss(animated: true, completion: nil)
                }
                
            }
            
        }
        
        let duzenleAction = UIAlertAction(title: "Yorumu Düzenle", style: .default) { (action) in
            //yorum düzenlenecek
            
            self.performSegue(withIdentifier: "YorumDuzenleSegue", sender: (yorum,self.secilenFikir)) // tuple yapısı
            self.dismiss(animated: true, completion: nil)
            
        }
        let iptalAction = UIAlertAction(title: "İptal Et", style: .cancel, handler: nil)
        
        alert.addAction(silAction)
        alert.addAction(duzenleAction)
        alert.addAction(iptalAction)
        present(alert, animated: true, completion: nil)
        
    }
}
