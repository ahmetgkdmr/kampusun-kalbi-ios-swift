
import UIKit
import FirebaseAuth

class YorumCell: UITableViewCell {

    
    @IBOutlet weak var lblKullaniciAdi: UILabel!
    @IBOutlet weak var lblTarih: UILabel!
    @IBOutlet weak var lblYorum: UILabel!
    
    @IBOutlet weak var imgSecenekler: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    var delegate : YorumDelegate?
    var secilenYorum : Yorum!
    
    func gorunumAyarla(yorum : Yorum,delegate : YorumDelegate?){
        
        lblKullaniciAdi.text = yorum.kullaniciAdi
        lblYorum.text = yorum.yorumText
        
        let tarihFormat = DateFormatter()
        tarihFormat.dateFormat = "dd MM YYYY, hh:mm"
        let eklenmeTarihi = tarihFormat.string(from: yorum.eklenmeTarihi)
        lblTarih.text = eklenmeTarihi
        
        secilenYorum = yorum
        self.delegate = delegate // YorumlarVC den gelen delegate i kendi delegate imize atadık. Yetkilendirme yaptık.
        
        
        imgSecenekler.isHidden = true // başta seçenekler kapalı
        
        if yorum.kullaniciId == Auth.auth().currentUser?.uid { // kullanıcının yorumuysa seçenekleri görebilir.
            imgSecenekler.isHidden = false
            
            // seçenekler fotosunu tıklanabilir yaptık.
            let tap = UITapGestureRecognizer(target: self, action: #selector(imgYorumSeceneklerPressed))
            imgSecenekler.isUserInteractionEnabled = true
            imgSecenekler.addGestureRecognizer(tap)
        }
        
    }
    
    @objc func imgYorumSeceneklerPressed() { // YorumlarVC de kullanıldı.
        delegate?.seceneklerYorumPressed(yorum: secilenYorum)
        
    }
    
    
}

protocol YorumDelegate { // YorumlarVC de kullanıyoruz.
    
    func seceneklerYorumPressed(yorum : Yorum)
    
}
