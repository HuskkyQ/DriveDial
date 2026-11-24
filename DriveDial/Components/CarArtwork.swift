import SwiftUI
import UIKit
import DriveDialCore

struct BitmapCar: View {
    var name: String
    var label: String

    var body: some View {
        Group {
            if UIImage(named: name) != nil {
                Image(name)
                    .resizable()
                    .renderingMode(.original)
                    .aspectRatio(contentMode: .fit)
            } else {
                Color.clear
            }
        }
        .accessibilityLabel(label)
    }
}
