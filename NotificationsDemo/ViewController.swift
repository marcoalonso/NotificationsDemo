//
//  ViewController.swift
//  NotificationsDemo
//
//  Created by marco rodriguez on 29/08/22.
//

import UIKit
import AVFoundation
import UserNotifications

class ViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var mensaje: UITextView!
    @IBOutlet weak var titulo: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    var reproductor: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mensaje.delegate = self
        
        notificationCenter.requestAuthorization(options: [.alert, .sound]) {
            (permissionGranted, error) in
            if(!permissionGranted) {
                DispatchQueue.main.async {
                    let ac = UIAlertController(title: "Habilitar las Notificaciones?", message: "Para poder utilizar esta característica, debes de permitir las notificaciones.", preferredStyle: .alert)
                    let goToSettings = UIAlertAction(title: "Ir a configuración.", style: .default)
                    { (_) in
                        guard let setttingsURL = URL(string: UIApplication.openSettingsURLString)
                        else
                        {
                            return
                        }
                        
                        if(UIApplication.shared.canOpenURL(setttingsURL)) {
                            UIApplication.shared.open(setttingsURL) { (_) in
                                
                            }
                        }
                    }
                    ac.addAction(goToSettings)
                    ac.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (_) in}))
                    self.present(ac, animated: true)
                }
            }
        }
        
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        mensaje.text = ""
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    @IBAction func programarNotificationButton(_ sender: UIButton) {
        notificationCenter.getNotificationSettings { (settings) in
            
            DispatchQueue.main.async {
                let title = self.titulo.text!
                let message = self.mensaje.text!
                let date = self.datePicker.date
                
                if(settings.authorizationStatus == .authorized) {
                    let content = UNMutableNotificationContent()
                    content.title = title
                    content.body = message
                    
                    
                    let dateComp = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComp, repeats: false)
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                    
                    self.notificationCenter.add(request) { (error) in
                        if(error != nil) {
                            print("Error " + error.debugDescription)
                            return
                        }
                    }
                    let ac = UIAlertController(title: "Notificacion Programada", message: "Para el " + self.formattedDate(date: date), preferredStyle: .alert)
                    
                    print("date: ", self.formattedDate(date: date))
                    
                    ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                        print("DEBUG: OK")
                        self.mensaje.text = ""
                        self.titulo.text = ""
                        self.datePicker.date = Date()
                    }))
                    self.present(ac, animated: true)
                } else {
                    let ac = UIAlertController(title: "Habilitar las Notificaciones?", message: "Para poder utilizar esta característica, debes de permitir las notificaciones.", preferredStyle: .alert)
                    let goToSettings = UIAlertAction(title: "Ir a configuración.", style: .default)
                    { (_) in
                        guard let setttingsURL = URL(string: UIApplication.openSettingsURLString)
                        else
                        {
                            return
                        }
                        
                        if(UIApplication.shared.canOpenURL(setttingsURL)) {
                            UIApplication.shared.open(setttingsURL) { (_) in
                                
                            }
                        }
                    }
                    ac.addAction(goToSettings)
                    ac.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (_) in}))
                    self.present(ac, animated: true)
                }
            }
        }
    }
    
    
    
    func formattedDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM y HH:mm"
        return formatter.string(from: date)
    }
    
}

