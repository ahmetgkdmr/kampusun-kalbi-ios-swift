
import Foundation
import UIKit


// komut + k ile klavyeyi açıp yazmaya çalıştığımızda klavye sorun çıkartıyordu. klavye yorum yazacağımız alanın üstüne çıkıyordu.
// bu sorunu objective c kullanarak çözmeye çalıştık. Klavye açıldığında sayfadaki genel view ona göre kendini ayarladı.

extension UIView{
    
    func klavyeAyarla(){
        
        // klavyenin konumu değiştiğinde bize haber veriyor ve fonskiyonu (klavyeKonumAyarla) tetikliyoruz.
        NotificationCenter.default.addObserver(self, selector: #selector(klavyeKonumAyarla(_ :)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
    }
    
    @objc private func klavyeKonumAyarla(_ notification : NSNotification){
        
        // klavye başlangıçtan bitiş kısmına kaç saniyede gelmiş onu bulur.
        let sure = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        
        // animasyonun nasıl bir eğimle olacağını söylüyor. her animasyonda olur.
        let curve = notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
        
        // başlangıç konumu
        let baslangicFrame = (notification.userInfo![UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        
        // bitiş konumu
        let bitisFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        // aradaki fark
        let farky = bitisFrame.origin.y - baslangicFrame.origin.y
        
        //
        UIView.animateKeyframes(withDuration: sure, delay: 0.0, options: UIView.KeyframeAnimationOptions.init(rawValue: curve), animations: {
            self.frame.origin.y += farky // hangi UIView da kullanıcaksak onun y eksenindeki konumunu kaydırdık.
        }, completion: nil)
        
        
        
    }
    
    
}
