//
//  ContentView.swift
//  Sway
//
//  Created by Lawrence Jones on 6/8/2025.
//

import SwiftUI

// Root
struct ContentView: View {
    var body: some View {
        SwayAuthView()
            .preferredColorScheme(.dark)
            .background(Color.black.ignoresSafeArea())
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().previewDevice("iPhone 15 Pro")
    }
}

// Auth screen
struct SwayAuthView: View {
    enum Mode { case login, signup }

    @State private var mode: Mode = .login
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var confirm = ""
    @State private var showPass = false
    @State private var agree = false
    @State private var loading = false
    @State private var error: String?
    @State private var message: String?

    private var passwordScore: Int { scorePassword(password) }

    var body: some View {
        VStack(spacing: 18) {

            // Logo + title (shows "S" fallback; replace/add asset named "SwayLogo")
            VStack(spacing: 10) {
                ZStack {
                    Text("S")
                        .font(.system(size: 72, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                    Image("SwayLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 96, height: 96)
                }
                Text("Sway")
                    .font(.title2).fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            .padding(.top, 8)

            // Tabs
            HStack(spacing: 8) {
                SegmentedTab("Log in", active: mode == .login) { mode = .login; clearBanners() }
                SegmentedTab("Sign up", active: mode == .signup) { mode = .signup; clearBanners() }
            }
            .padding(6)
            .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))

            // Forms
            if mode == .login { loginForm } else { signupForm }

            // Footer switch
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { mode = (mode == .login ? .signup : .login) }
                clearBanners()
            } label: {
                HStack(spacing: 4) {
                    Text(mode == .login ? "New to Sway?" : "Already have an account?")
                        .foregroundColor(.white.opacity(0.7))
                    Text(mode == .login ? "Create an account" : "Log in")
                        .foregroundColor(.red)
                }
                .font(.footnote)
            }
        }
        .frame(maxWidth: 540)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center) // centered
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    // MARK: Forms

    private var loginForm: some View {
        VStack(spacing: 12) {
            LabeledField(label: "Email", systemImage: "envelope", text: $email, isEmail: true)
            PasswordField(label: "Password", text: $password, show: $showPass)

            HStack {
                Toggle(isOn: .constant(false)) { Text("Remember me").font(.footnote).foregroundColor(.white) }
                    .toggleStyle(.switch)
                    .tint(.red)
                Spacer()
                Button("Forgot password?") {}
                    .font(.footnote)
                    .foregroundColor(.red)
            }
            .padding(.vertical, 4)

            if let error { Banner(text: error, isError: true) }
            if let message { Banner(text: message, isError: false) }

            Button(action: onLogin) {
                HStack {
                    if loading { ProgressView().controlSize(.small) }
                    Image(systemName: "arrow.right")
                    Text("Log in").fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red) // red primary
            .disabled(loading)

            OAuthButtons()
        }
    }

    private var signupForm: some View {
        VStack(spacing: 12) {
            VStack(spacing: 12) {
                LabeledField(label: "Display name", systemImage: "person", text: $name)
                LabeledField(label: "Email", systemImage: "envelope", text: $email, isEmail: true)
            }

            PasswordField(label: "Password", text: $password, show: $showPass)
            PasswordStrength(score: passwordScore)
            PasswordField(label: "Confirm password", text: $confirm, show: $showPass)

            Toggle(isOn: $agree) {
                Text("I agree to the Terms and Privacy Policy")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.9))
            }
            .tint(.red)

            if let error { Banner(text: error, isError: true) }
            if let message { Banner(text: message, isError: false) }

            Button(action: onSignup) {
                HStack {
                    if loading { ProgressView().controlSize(.small) }
                    Image(systemName: "arrow.right")
                    Text("Create account").fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red) // red primary
            .disabled(loading)

            OAuthButtons()
        }
    }

    // MARK: Actions

    private func clearBanners() { error = nil; message = nil }

    private func onLogin() {
        clearBanners()
        if let e = validateLogin(email: email, password: password) { error = e; return }
        loading = true
        Task {
            let res = await fakeFetch("/api/login", ["email": email, "password": password])
            loading = false
            if res.ok { message = "Welcome back! Redirecting…" } else { error = res.error ?? "Login failed" }
        }
    }

    private func onSignup() {
        clearBanners()
        if let e = validateSignup(name: name, email: email, password: password, confirm: confirm, agree: agree) { error = e; return }
        loading = true
        Task {
            let res = await fakeFetch("/api/signup", ["name": name, "email": email, "password": password])
            loading = false
            if res.ok { message = "Account created! Check your email to verify." } else { error = res.error ?? "Sign-up failed" }
        }
    }
}

// MARK: Pieces

private struct SegmentedTab: View {
    let title: String
    let active: Bool
    let action: () -> Void
    init(_ title: String, active: Bool, action: @escaping () -> Void) {
        self.title = title; self.active = active; self.action = action
    }
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline).fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(active ? Color.white.opacity(0.1) : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10)
                    .stroke(active ? Color.red.opacity(0.6) : Color.white.opacity(0.15), lineWidth: 1))
                .foregroundColor(.white.opacity(active ? 1 : 0.8))
        }
        .buttonStyle(.plain)
    }
}

private struct LabeledField: View {
    let label: String
    let systemImage: String
    @Binding var text: String
    var isEmail: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label).font(.footnote).fontWeight(.semibold).foregroundColor(.white)
            HStack(spacing: 10) {
                Image(systemName: systemImage).foregroundColor(.white).opacity(0.85)

                // Base field (cross-platform)
                var field = TextField(label, text: $text)
                    .foregroundColor(.white)
                    .disableAutocorrection(true)

                // iOS niceties (guarded so macOS builds too)
                #if os(iOS)
                if isEmail { field = field.keyboardType(.emailAddress) }
                field = field.textInputAutocapitalization(.never)
                #endif

                field
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.12), lineWidth: 1))
        }
    }
}

private struct PasswordField: View {
    let label: String
    @Binding var text: String
    @Binding var show: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label).font(.footnote).fontWeight(.semibold).foregroundColor(.white)
            HStack(spacing: 10) {
                Image(systemName: "lock").foregroundColor(.white).opacity(0.85)

                if show {
                    var field = TextField(label, text: $text)
                        .foregroundColor(.white)
                        .disableAutocorrection(true)
                    #if os(iOS)
                    field = field.textInputAutocapitalization(.never)
                    #endif
                    field
                } else {
                    SecureField(label, text: $text).foregroundColor(.white)
                }

                Button {
                    show.toggle()
                } label: {
                    Image(systemName: show ? "eye.slash" : "eye")
                        .imageScale(.small)
                        .foregroundColor(.white)
                        .padding(6)
                        .background(Color.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.12), lineWidth: 1))
        }
    }
}

private struct PasswordStrength: View {
    let score: Int
    private let labels = ["Very weak", "Weak", "OK", "Good", "Strong"]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.15))
                    Capsule()
                        .fill(Color.red)
                        .frame(width: geo.size.width * CGFloat(score + 1) / 5.0)
                        .animation(.easeInOut(duration: 0.25), value: score)
                }
            }
            .frame(height: 8)
            Text("Password strength: \(labels[max(0, min(score, 4))])")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.top, 2)
    }
}

private struct Banner: View {
    let text: String
    let isError: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isError ? "exclamationmark.triangle" : "checkmark.circle")
            Text(text).font(.subheadline)
            Spacer(minLength: 0)
        }
        .foregroundColor(isError ? .red : .green)
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke((isError ? Color.red : Color.green).opacity(0.5), lineWidth: 1)
                .background(
                    (isError ? Color.red : Color.green).opacity(0.12)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                )
        )
    }
}

private struct OAuthButtons: View {
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Rectangle().fill(Color.white.opacity(0.15)).frame(height: 1)
                Text("or continue with").font(.caption).foregroundColor(.white.opacity(0.6))
                Rectangle().fill(Color.white.opacity(0.15)).frame(height: 1)
            }
            HStack(spacing: 10) {
                GhostButton(title: "Continue with Google")
                GhostButton(title: "Continue with Apple")
            }
        }
    }
}

private struct GhostButton: View {
    let title: String
    var body: some View {
        Button(title) {}
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .foregroundColor(.white)
            .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.12)))
    }
}

// MARK: Validation & Fake API

private func validateLogin(email: String, password: String) -> String? {
    if !isValidEmail(email) { return "Please enter a valid email." }
    if password.isEmpty { return "Please enter your password." }
    return nil
}
private func validateSignup(name: String, email: String, password: String, confirm: String, agree: Bool) -> String? {
    if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return "Please enter a display name." }
    if !isValidEmail(email) { return "Please enter a valid email." }
    if password.count < 8 { return "Password must be at least 8 characters." }
    if scorePassword(password) < 2 { return "Password is too weak. Try adding numbers and symbols." }
    if password != confirm { return "Passwords do not match." }
    if !agree { return "You need to agree to the Terms and Privacy Policy." }
    return nil
}
private func isValidEmail(_ email: String) -> Bool {
    let r = #"^[^\s@]+@[^\s@]+\.[^\s@]+$"#
    return email.range(of: r, options: .regularExpression) != nil
}
private func scorePassword(_ pw: String) -> Int {
    var s = 0
    if pw.count >= 8 { s += 1 }
    if pw.count >= 12 { s += 1 }
    if pw.rangeOfCharacter(from: .uppercaseLetters) != nil &&
       pw.rangeOfCharacter(from: .lowercaseLetters) != nil { s += 1 }
    if pw.rangeOfCharacter(from: .decimalDigits) != nil { s += 1 }
    if pw.range(of: #"[^A-Za-z0-9]"#, options: .regularExpression) != nil { s += 1 }
    return min(4, s - 1)
}
private struct FakeResponse { let ok: Bool; let error: String? }
private func fakeFetch(_ url: String, _ body: [String: Any]) async -> FakeResponse {
    try? await Task.sleep(nanoseconds: 900_000_000)
    return FakeResponse(ok: true, error: nil)
}
