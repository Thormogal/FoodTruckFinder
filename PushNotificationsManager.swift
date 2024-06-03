//
//  PushNotificationsManager.swift
//  FoodTruckFinder
//
//  Created by Frida Dahlqvist on 2024-06-03.
//

import Foundation

func sendPushNotification(to token: String, title: String, body: String) {
    let urlString = "https://fcm.googleapis.com/v1/projects/foodtruckfinder-c38a2/messages:send"
    guard let url = URL(string: urlString) else { return }
    let accessToken = "ya29c..c0AY_VpZgwYe7NvwbYy6Zr5pIUFXef5NgoALjqVKxU69FgqNH25OBKBqT5axGAjrGnNnniIv0GDD7OhTR3-kMLvBymIWOGyWEKzslQCo29s8KHrcZFvDbXjaoglEyk1Uh93zGJPgG7ZE8gsQmt96-c78LQVCXQ-wszLJ_f-cA75fhm8CAV_OUjDXOWYAjBMfWfSj5ubv7CJrOhjTBpPa2it3orHMnDNgBHUis0t2tLzsApTuxg50AVESyS940Ko8QCUbG93bDmXB7mPZsPT0XQ7VqalzyfMLEAuI0kTpNSXlrrXVXo6AWegp1jHhVJLX-L6hC74oUjDxJhECwbNbrWzsLJ2lqdaE_D5zm5rBcVQjhPAc5lJj1FT3u40QLMZlFl5ssKUtAL400CBqr0etv-YMJpZ7spsRSpc01kxYlySpxomMZmB5wyMlw3BzFUihU3XSUJyo8Bcr7q_hqiixqSjZnb1_WM0wo0kl4ug45rFqgXnx0hrZF-x4XsbuB5beYsJVSYX_-p0wo-o0uxd7kFFp3wVFtzyg_WmzrsjMwnO4IFfQjuedOldJluqk_wte8omm_6w7yl7ORSkji5hrQcjd98mmfjR8oZhjUVIhB72Mal9jlrxeeR4Yp6vjBpOffYqZjWhtcdgexvnRrriIJX89W73FehIm3v_v-FQFySsdtXoO91YUvZfQnh-jRMtrn54WnY2amav1OBqsrJf5ikqjcRkr0V_4e2lmUF78SOXYVMw5qUS1YcRalpYIXMbJJkwpc4BupQicFMSJ0df77aUslbj1f7sJ9jbu5F8jitadBerZubpJfWjriosU16R7OhcUsYmyBQ6Ygj4yfzg1vigu7JW83fIndRy6eVoaQ8_kuk5O41dUX1SqBqRfdbdyBB3bQrke3ptU5XXSbcssS7JpB7O_UB2v-9Z8mSme9r-vmXIiysq4-9yWu6FRMo6ySvpvjj0RiytwMiXVekRbwtMi_ViR3BWFs49XFgRzmfjjjOm1agdnjxhrs"
    

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

    let message: [String: Any] = [
        "message": [
            "token": token,
            "notification": [
                "title": title,
                "body": body
            ]
        ]
    ]

    do {
        let jsonData = try JSONSerialization.data(withJSONObject: message, options: .prettyPrinted)
        request.httpBody = jsonData
    } catch {
        print("Error serializing JSON: \(error)")
        return
    }

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error sending push notification: \(error)")
            return
        }

        if let data = data, let responseString = String(data: data, encoding: .utf8) {
            print("Response: \(responseString)")
        }
    }
    task.resume()
}

// Använd funktionen
//sendPushNotification(to: "RECIPIENT_DEVICE_TOKEN", title: "Hello", body: "World")
