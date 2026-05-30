import SwiftUI

struct PinSettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var currentPin = ""
    @State private var newPin = ""
    @State private var confirmPin = ""
    @State private var errorMessage: String?
    @State private var successMessage: String?

    private let pinLength = 4

    var body: some View {
        let pinSet = PinManager.isPinSet

        List {
            if !pinSet {
                Section("Utwórz PIN") {
                    SecureField("Wprowadź PIN (4 cyfry)", text: $newPin)
                        .keyboardType(.numberPad)
                        .onChange(of: newPin) { _ in limitLength(&newPin) }
                    SecureField("Potwierdź PIN", text: $confirmPin)
                        .keyboardType(.numberPad)
                        .onChange(of: confirmPin) { _ in limitLength(&confirmPin) }

                    Button("Ustaw PIN") {
                        setPin()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(newPin.isEmpty || confirmPin.isEmpty)
                }
            } else {
                Section("Zmień PIN") {
                    SecureField("Stary PIN", text: $currentPin)
                        .keyboardType(.numberPad)
                        .onChange(of: currentPin) { _ in limitLength(&currentPin) }
                    SecureField("Nowy PIN (4 cyfry)", text: $newPin)
                        .keyboardType(.numberPad)
                        .onChange(of: newPin) { _ in limitLength(&newPin) }
                    SecureField("Potwierdź nowy PIN", text: $confirmPin)
                        .keyboardType(.numberPad)
                        .onChange(of: confirmPin) { _ in limitLength(&confirmPin) }

                    Button("Zmień PIN") {
                        changePin()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(currentPin.isEmpty || newPin.isEmpty || confirmPin.isEmpty)
                }

                Section {
                    Button("Usuń PIN", role: .destructive) {
                        removePin()
                    }
                    .disabled(currentPin.isEmpty)
                }
            }

            if let error = errorMessage {
                Text(error)
                    .foregroundStyle(.red)
            }
            if let success = successMessage {
                Text(success)
                    .foregroundStyle(.green)
            }
        }
        .navigationTitle("Ustawienia PIN")
        .onDisappear {
            errorMessage = nil
            successMessage = nil
        }
    }

    private func limitLength(_ text: inout String) {
        if text.count > pinLength {
            text = String(text.prefix(pinLength))
        }
    }

    private func setPin() {
        guard newPin.count == pinLength else {
            errorMessage = "PIN musi mieć \(pinLength) cyfry"
            return
        }
        guard newPin == confirmPin else {
            errorMessage = "PIN-y nie są zgodne"
            return
        }
        PinManager.storePin(newPin)
        clearForm()
        successMessage = "PIN został ustawiony"
        dismiss()
    }

    private func changePin() {
        guard newPin.count == pinLength else {
            errorMessage = "PIN musi mieć \(pinLength) cyfry"
            return
        }
        guard newPin == confirmPin else {
            errorMessage = "PIN-y nie są zgodne"
            return
        }
        guard PinManager.changePin(from: currentPin, to: newPin) else {
            errorMessage = "Stary PIN jest nieprawidłowy"
            return
        }
        clearForm()
        successMessage = "PIN został zmieniony"
    }

    private func removePin() {
        guard PinManager.verifyPin(currentPin) else {
            errorMessage = "PIN jest nieprawidłowy"
            return
        }
        PinManager.removePin()
        clearForm()
        successMessage = "PIN został usunięty"
        dismiss()
    }

    private func clearForm() {
        currentPin = ""
        newPin = ""
        confirmPin = ""
        errorMessage = nil
    }
}
