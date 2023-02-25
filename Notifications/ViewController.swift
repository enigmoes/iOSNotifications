//
//  ViewController.swift
//  Notifications
//
//  Created by Joel on 9/9/22.
//

import UIKit
import UserNotifications

class ViewController: UIViewController
{
    
    @IBOutlet weak var titleNotify: UITextField!
    @IBOutlet weak var messageNotify: UITextField!
    @IBOutlet weak var datePickerNotify: UIDatePicker!
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationCenter.requestAuthorization(options: [.alert, .sound]) {
            (permissionGranted, error) in
            if (!permissionGranted) {
                print("Permiso Denegado")
            }
        }
    }

    @IBAction func scheduleAction(_ sender: Any) {
        notificationCenter.getNotificationSettings { (settings) in
            DispatchQueue.main.async {
                let title = self.titleNotify.text!
                let message = self.messageNotify.text!
                let date = self.datePickerNotify.date
                
                if (settings.authorizationStatus == .authorized) {
                    let content = UNMutableNotificationContent()
                    content.title = title
                    content.body = message
                    
                    let dateComp = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComp, repeats: false)
                    
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                    
                    self.notificationCenter.add(request) { (error) in
                        if (error != nil) {
                            print("Error: " + error.debugDescription)
                            return
                        }
                    }
                    
                    let ac = UIAlertController(title: "Notificacion Programada", message: "At " + formattedDate(date: date), preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in}))
                    self.present(ac, animated: true)
                } else {
                    let ac = UIAlertController(title: "Desea habilitar las notificaciones?", message: "Para utilizar esta app, debe habilitar las notificaciones en la configuración", preferredStyle: .alert)
                    let goToSettings = UIAlertAction(title: "Configuracion", style: .default) { (_) in
                        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
                            return
                        }
                        
                        if (UIApplication.shared.canOpenURL(settingsURL))
                        {
                            UIApplication.shared.open(settingsURL) { (_) in }
                        }
                    }
                    ac.addAction(goToSettings)
                    ac.addAction(UIAlertAction(title: "Cancelar", style: .default, handler: { (_) in}))
                    self.present(ac, animated: true)
                }
            }
        }
        
        func formattedDate(date: Date) -> String
        {
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM y HH:mm"
            return formatter.string(from: date)
        }
    }
    
}

