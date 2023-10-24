//
//  AuthenticationManager.swift
//  Torch
//
//  Created by Parth Saxena on 6/13/23.
//

import Foundation
import Amplify
import AWSCognitoAuthPlugin

//enum AuthState {
//    case signUp
//    case inputEmail
//    case inputPassword
//    case confirmEmailCode
//    case inputName
//
//    case login
//    case loginEmail
//    case loginPassword
//
//    case session(user: AuthUser)
//}

enum AuthState: Int {
    case welcome
    case login
    
    case accountName
    case accountEmail
    case companyName
    case accountPassword
    case accountVerificationCode
    
    case authenticated
}

class AuthenticationManager: ObservableObject {
    static let shared = AuthenticationManager()
    
    @Published var authState: AuthState = .welcome    
    @Published var authUser: AuthUser!
    
    @Published var authStateLoaded: Bool = false
    
    var email: String?
    var password: String?
    
    init() {
        //        
    }
        
    func fetchCurrentAuthSession() async {
        do {
            let session = try await Amplify.Auth.fetchAuthSession()
            if session.isSignedIn {
                let user = try await Amplify.Auth.getCurrentUser()
                // print("Got user")
                DispatchQueue.main.async {
                    self.authUser = user
                    self.authState = .authenticated
                    self.authStateLoaded = true
                    
                    // Load property & device data
                    SessionManager.shared.loadUserProperties()
                }
            } else {
                DispatchQueue.main.async {
                    self.authStateLoaded = true
                }
            }
            
            // print("Is user signed in - \(session.isSignedIn)")
        } catch let error as AuthError {
            // print("Fetch session failed with error \(error)")
        } catch {
            // print("Unexpected error: \(error)")
        }
    }
    
    func signIn(email: String, password: String) async {
        do {
            let signInResult = try await Amplify.Auth.signIn(username: email, password: password)
            
            // print("Sign in result: \(signInResult)")
            
            if signInResult.isSignedIn {
                
                let user = try await Amplify.Auth.getCurrentUser()
                // print("Got user")
                DispatchQueue.main.async {
                    self.authUser = user
                    self.authState = .authenticated
                    
                    // Load property & device data
                    SessionManager.shared.loadUserProperties()
                }
                // print("Sign in succeeded: \(self.authUser)")
            }
        } catch let error as AuthError {
            // print("Sign in failed \(error)")
        } catch {
            // print("Unexpected error: \(error)")
        }
    }
    
    func signupPostSignIn(email: String, password: String) async {
        do {
            let signInResult = try await Amplify.Auth.signIn(username: email, password: password)
            
            // print("Sign in result: \(signInResult)")
            
            if signInResult.isSignedIn {
                
                let user = try await Amplify.Auth.getCurrentUser()
                // print("Got user")
                DispatchQueue.main.async {
                    self.authUser = user
                    SessionManager.shared.createUserData(email: email)
                    DispatchQueue.main.async {
                        SessionManager.shared.propertiesLoaded = true
                    }
//                    self.authState = .authenticated
                }
                // print("Sign in succeeded: \(self.authUser)")
            }
        } catch let error as AuthError {
            // print("Sign in failed \(error)")
        } catch {
            // print("Unexpected error: \(error)")
        }
    }
    
    func signUp(email: String, password: String) async {
        let userAttributes = [AuthUserAttribute(.email, value: email)]
        let options = AuthSignUpRequest.Options(userAttributes: userAttributes)
        
        do {
            let signUpResult = try await Amplify.Auth.signUp(
                username: email,
                password: password,
                options: options
            )
            
            self.email = email
            self.password = password
            
            if case let .confirmUser(deliveryDetails, _, userId) = signUpResult.nextStep {
                DispatchQueue.main.async {
                    self.authState = .accountVerificationCode
                }
                // print("AuthState: \(authState) Delivery details \(String(describing: deliveryDetails)) for userId: \(String(describing: userId))")
            } else {
                // print("SignUp Complete")
            }
        } catch let error as AuthError {
            // print("An error occurred while registering a user \(error)")
        } catch {
            // print("Unexpected error: \(error)")
        }
    }
    
    func gotNewVerificationCode(code: String) async {
        // print("Got code=\(code)")
        
        await self.confirm(
            email: email!,
            code: code
        )
    }
    
    func confirm(email: String, code: String) async {
        do {
               let confirmSignUpResult = try await Amplify.Auth.confirmSignUp(
                   for: email,
                   confirmationCode: code
               )
               // print("Confirm sign up result completed: \(confirmSignUpResult.isSignUpComplete)")
            if confirmSignUpResult.isSignUpComplete {
                await signupPostSignIn(email: email, password: password!)
            }
           } catch let error as AuthError {
               // print("An error occurred while confirming sign up \(error)")
           } catch {
               // print("Unexpected error: \(error)")
           }
    }
    
    func signOut() async {
        let result = await Amplify.Auth.signOut()
        
        guard let signOutResult = result as? AWSCognitoSignOutResult
        else {
            // print("Signout failed")
            return
        }

        // print("Local signout successful: \(signOutResult.signedOutLocally)")
        switch signOutResult {
        case .complete:
            // Sign Out completed fully and without errors.
            // print("Signed out successfully")
            SessionManager.shared.clearData()
            self.authState = .welcome

        case let .partial(revokeTokenError, globalSignOutError, hostedUIError):
            // Sign Out completed with some errors. User is signed out of the device.
            
            if let hostedUIError = hostedUIError {
                // print("HostedUI error  \(String(describing: hostedUIError))
            }

            if let globalSignOutError = globalSignOutError {
                // Optional: Use escape hatch to retry revocation of globalSignOutError.accessToken.
                // print("GlobalSignOut error  \(String(describing: globalSignOutError))
            }

            if let revokeTokenError = revokeTokenError {
                // Optional: Use escape hatch to retry revocation of revokeTokenError.accessToken.
                // print("Revoke token error  \(String(describing: revokeTokenError))
            }

        case .failed(let error):
            // Sign Out failed with an exception, leaving the user signed in.
             print("SignOut failed with \(error)")
        }
    }
}
