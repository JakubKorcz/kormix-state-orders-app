import SwiftUI

struct PinLockView: View {
    @State private var pin = ""
    @State private var errorMessage: String?
    @FocusState private var isFocused: Bool

    var onUnlock: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "lock.shield")
                .font(.system(size: 60))
                .foregroundStyle(.green)

            Text("KORMIX Planer")
                .font(.title2.bold())

            Text("Wprowadź PIN, aby odblokować")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            SecureField("PIN", text: $pin)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                .frame(maxWidth: 200)
                .multilineTextAlignment(.center)
                .focused($isFocused)

            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            Button("Odblokuj") {
                if PinManager.verifyPin(pin) {
                    onUnlock()
                } else {
                    errorMessage = "Nieprawidłowy PIN"
                    pin = ""
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(pin.isEmpty)

            Spacer()
        }
        .padding()
        .onAppear { isFocused = true }
    }
}
