[README.md](https://github.com/user-attachments/files/31652932/README.md)
# IDentity Medium SDK for iOS

[![Platform](https://img.shields.io/badge/platform-iOS%2015%2B-lightgrey.svg)](https://developer.apple.com)
[![Swift Tools](https://img.shields.io/badge/swift--tools-5.9-orange.svg)](https://swift.org)
[![SPM](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://swift.org/package-manager)
[![License](https://img.shields.io/badge/license-Proprietary-red.svg)](LICENSE)

The **IDentity Medium SDK** is IDmission's balanced-footprint identity verification SDK for iOS. It performs
document detection, cropping, realness checks, MRZ and barcode reading, face detection, and passive liveness
**on the device**, and defers heavier document classification and front-side OCR to the IDmission platform.

This repository distributes the SDK as a **Swift Package** of pre-built, code-signed `.xcframework` binaries.

> [!IMPORTANT]
> This is commercial, proprietary software. Cloning or resolving this package does **not** grant you a licence
> to use it, and the SDK will not function without credentials issued by IDmission. See [LICENSE](LICENSE) and
> contact <sales@idmission.com> to obtain a commercial agreement.

---

## Table of contents

- [Which SDK flavour do I need?](#which-sdk-flavour-do-i-need)
- [Requirements](#requirements)
- [Package products](#package-products)
- [Installation](#installation)
- [Project configuration](#project-configuration)
- [Credentials and access tokens](#credentials-and-access-tokens)
- [Initializing the SDK](#initializing-the-sdk)
- [Tracking initialization progress](#tracking-initialization-progress)
- [Features](#features)
- [ePassport NFC chip reading](#epassport-nfc-chip-reading)
- [Localization](#localization)
- [Security controls](#security-controls)
- [Diagnostics](#diagnostics)
- [Framework sizes](#framework-sizes)
- [Versioning and releases](#versioning-and-releases)
- [Troubleshooting](#troubleshooting)
- [Support](#support)
- [Licence](#licence)

---

## Which SDK flavour do I need?

IDmission ships several iOS SDK flavours. They share one API surface; they differ in how much processing runs
on the device versus on the IDmission platform, and therefore in binary size and offline capability.

| Capability | **Medium** (this SDK) | [Lite](https://github.com/Idmission-LLC/identityLiteSDK-SPM) | [Liveness](https://github.com/Idmission-LLC/identityLivenessSDK-SPM) |
|:---|:---:|:---:|:---:|
| Document detection, rotate and crop | On device | On device | — |
| Document realness | On device | On server | — |
| Document classification | On server | On server | — |
| MRZ and barcode reading | On device | On server | — |
| OCR from document front | On server | On server | — |
| Face detection | On device | On device | On device |
| Passive liveness detection | On device | On device | On device |
| Face mask detection | On device | On device | On device |
| Hat and sunglasses detection | On device | On server | On server |
| ePassport NFC chip reading | Optional add-on | — | — |

For the Video ID and Full flavours, which additionally run classification and front-side OCR on the device,
contact <sales@idmission.com>.

---

## Requirements

| | |
|:---|:---|
| **Minimum deployment target** | iOS 15.0 |
| **Xcode** | 15.0 or later |
| **Swift tools version** | 5.9 |
| **Device architecture** | `arm64` |
| **Simulator architecture** | `x86_64` only — see [Apple Silicon note](#apple-silicon-simulators) |
| **Third-party dependencies** | **None.** |
| **Network** | HTTPS access to your IDmission API host and to the model CDN |


### Apple Silicon simulators

The shipped `.xcframework` bundles contain an `arm64` device slice and an **`x86_64` simulator slice**. There
is no `arm64` simulator slice, so on an Apple Silicon Mac a default simulator build will fail to find the
module. Choose one of:

1. **Build and test on a physical device** — recommended, and required anyway for camera and NFC work.
2. **Build the simulator target as `x86_64`.** In your app target's build settings add:

   ```
   EXCLUDED_ARCHS[sdk=iphonesimulator*] = arm64
   ```

   The simulator then runs your app under Rosetta 2.

---

## Package products

Add only the products you need. Each product is a separate library, so unused capture modules are never
linked into your app.

| Product | Modules you `import` | Required | Purpose |
|:---|:---|:---:|:---|
| `IDentityMediumSDK` | `IDentityMediumSDK`, `IDCaptureMedium`, `SelfieCaptureMedium` | **Yes** | Core SDK, document capture, and selfie/liveness capture |
| `IDentityMediumModels` | *(none — see below)* | No | Bundles the ML models **inside your app** instead of downloading them on first run |
| `IDentityMediumNFC` | *(none — see below)* | No | ePassport chip reading over NFC |
| `SignatureCaptureMediumSDK` | `SignatureCaptureMedium` | No | Signature capture |
| `VoiceCaptureMediumSDK` | `VoiceCaptureMedium` | No | Voice capture |
| `FingerPrintCaptureMediumSDK` | `FingerPrintCaptureMedium` | No | Fingerprint capture |

> [!TIP]
> For the three optional capture products, the **product name and the module name differ** — the product is
> `SignatureCaptureMediumSDK` but you write `import SignatureCaptureMedium`.

### About `IDentityMediumModels`

The SDK needs a set of TensorFlow Lite models to run on-device inference. You choose how they arrive:

- **Omit the product** (default): models are downloaded from IDmission on first initialization. Smallest app
  binary, but the first launch needs network access and takes longer.
- **Include the product**: the models ship inside your app (about 21 MB uncompressed). First launch is fast
  and works without model downloads.

Either way, call `initializeSDK` with `isUpdateModelsData: true` so the SDK can refresh models when IDmission
publishes newer versions.

---

## Installation

### Xcode

1. **File → Add Package Dependencies…**
2. Enter the package URL:

   ```
   https://github.com/Idmission-LLC/identityMediumSDK-SPM
   ```

3. Set **Dependency Rule** to **Up to Next Major Version** starting at `11.1.17`.
4. Click **Add Package**, then tick the products you need. `IDentityMediumSDK` is mandatory.

### Package.swift

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "YourApp",
    platforms: [.iOS(.v15)],
    dependencies: [
        .package(
            url: "https://github.com/Idmission-LLC/identityMediumSDK-SPM",
            from: "11.1.17"
        )
    ],
    targets: [
        .target(
            name: "YourApp",
            dependencies: [
                .product(name: "IDentityMediumSDK", package: "identityMediumSDK-SPM"),
                // Optional:
                // .product(name: "IDentityMediumModels",           package: "identityMediumSDK-SPM"),
                // .product(name: "IDentityMediumNFC",              package: "identityMediumSDK-SPM"),
                // .product(name: "SignatureCaptureMediumSDK",      package: "identityMediumSDK-SPM"),
                // .product(name: "VoiceCaptureMediumSDK",          package: "identityMediumSDK-SPM"),
                // .product(name: "FingerPrintCaptureMediumSDK",    package: "identityMediumSDK-SPM"),
            ]
        )
    ]
)
```

### Repository access

If your organisation resolves this package over SSH, or if IDmission has provisioned it as a private
repository for you, make sure Xcode has a GitHub account configured with access
(**Xcode → Settings → Accounts**), or use the SSH form of the URL:

```
git@github.com:Idmission-LLC/identityMediumSDK-SPM.git
```

For CI, provide a deploy key or a personal access token with `repo` read scope.

---

## Project configuration

### Info.plist permissions

Add the purpose strings for the capabilities you actually use. Each string is shown to the end user in the
system permission prompt, so write it for your users, not for the SDK.

| Key | Required when |
|:---|:---|
| `NSCameraUsageDescription` | **Always** — every capture flow uses the camera |
| `NSLocationWhenInUseUsageDescription` | You initialize with `isGPSEnabled: true` |
| `NSMicrophoneUsageDescription` | You use `VoiceCaptureMediumSDK` |
| `NSSpeechRecognitionUsageDescription` | You use `VoiceCaptureMediumSDK` |
| `NFCReaderUsageDescription` | You use `IDentityMediumNFC` |

```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to scan your ID document and verify your identity.</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Your location is recorded with your verification to help prevent fraud.</string>
```

### App privacy manifest

The SDK ships its **own** `PrivacyInfo.xcprivacy` inside each framework, so you do not need to redeclare the
SDK's API usage. You still need an app-level `PrivacyInfo.xcprivacy` describing **your** app. If your app code
touches the same required-reason APIs, declare them with these reason codes:

| API category | Reason codes |
|:---|:---|
| File timestamp | `C617.1`, `3B52.1` |
| System boot time | `35F9.1` |
| Disk space | `E174.1` |
| User defaults | `CA92.1`, `1C8F.1`, `C56D.1` |

Remember to complete your App Store Connect privacy nutrition labels. The SDK collects name, email, phone,
physical address, payment info, precise and coarse location, sensitive info, photos or videos, audio data,
and user ID — all linked to the user, all for app functionality, none used for tracking.

---

## Credentials and access tokens

The SDK authenticates to the IDmission platform with a short-lived OAuth access token.

> [!WARNING]
> **Mint tokens on your backend, never in the app.** Your `client_id`, `client_secret`, username, and password
> must never be embedded in the app binary or in client-side configuration. Your app should request a token
> from your own server and pass it to `initializeSDK`.

IDmission provides your credentials when you sign up. Your server exchanges them for a token:

```bash
curl --location --request POST 'https://auth.idmission.com/auth/realms/identity/protocol/openid-connect/token' \
  --header 'Content-Type: application/x-www-form-urlencoded' \
  --data-urlencode 'grant_type=password' \
  --data-urlencode 'client_id=YOUR_CLIENT_ID' \
  --data-urlencode 'client_secret=YOUR_CLIENT_SECRET' \
  --data-urlencode 'username=YOUR_INTEG_USER' \
  --data-urlencode 'password=YOUR_PASSWORD' \
  --data-urlencode 'scope=api_access'
```

```json
{
  "access_token": "eyJhbGciO...",
  "expires_in": 18000,
  "token_type": "Bearer",
  "scope": "email profile api_access"
}
```

Tokens expire (`expires_in` is in seconds). Re-initialize the SDK with a fresh token when it lapses.

---

## Initializing the SDK

Initialize once, early in the session, before presenting any capture flow.

```swift
import IDentityMediumSDK
import IDCaptureMedium
import SelfieCaptureMedium

// Point the SDK at your IDmission environment before initializing.
IDentitySDK.apiBaseUrl = "https://api.idmission.com/"

IDentitySDK.initializeSDK(
    language: .en,              // .en, .es, or .none
    isGPSEnabled: true,         // attach geolocation to submissions
    geolocationRequired: false, // true = fail initialization without a location fix
                                // (requires isGPSEnabled: true)
    isUpdateModelsData: true,   // refresh on-device models when newer ones exist
    accessToken: accessToken    // token minted by your backend
) { error in
    if let error {
        // Handle initialization failure
        print("SDK init failed:", error.localizedDescription)
    } else {
        // Ready — capture flows may now be presented
    }
}
```

Check `IDentitySDK.isInitialized` before presenting a capture flow if the initialization result is not in
scope.

---

## Tracking initialization progress

Initialization logs in, downloads templates, and fetches any missing models. To drive a progress UI, adopt
`InitializationDelegate`:

> [!IMPORTANT]
> `InitializationStage` declares cases that this flavour never emits. Do not wait on them — a readiness
> check that blocks on a stage which never fires will hang forever. The stages this SDK actually reports are
> listed below.

```swift
final class SplashViewController: UIViewController, InitializationDelegate {

    private var states: [InitializationStage: InitializationState] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        IDentitySDK.delegate = self
    }

    func updateInitialization(stage: InitializationStage, state: InitializationState) {
        states[stage] = state
        print("\(stage.rawValue): \(state.rawValue)")

        // Terminal states for a login/config stage.
        let configDone: Set<InitializationState> = [.ok, .downloaded]
        // Model stages may legitimately end in .error and fall back to a server call.
        let modelDone: Set<InitializationState> = [.ok, .downloadedFromS3, .error]

        let modelStages: [InitializationStage] = [
            .faceFullRangeSparseTrainingModelLabel,
            .faceLandmarksDetectorTrainingModelLabel,
            .faceBlendshapesDetectorTrainingModelLabel,
            .passiveFaceTrainingModelLabel,
            .faceMaskTrainingModelLabel,
            .focusFaceTrainingModelLabel,
            .idCaptureTrainingModelLabel,
            .docDetectionTrainingModelLabel,
            .fingerprintDetectionTrainingModelLabel,
            .focusTrainingModelLabel
        ]

        let ready =
            states[.login] == .downloaded &&
            configDone.contains(states[.getXsltData] ?? .paused) &&
            configDone.contains(states[.searchCompanyTemplateDetails] ?? .paused) &&
            modelStages.allSatisfy { modelDone.contains(states[$0] ?? .paused) }

        if ready {
            showContinueButton()
        } else if [states[.login], states[.getXsltData], states[.searchCompanyTemplateDetails]]
                    .contains(.error) {
            showRetry()
        }
    }
}
```

**Stages reported by the Medium SDK (13):** `login`, `getXsltData`, `searchCompanyTemplateDetails`,
`faceFullRangeSparseTrainingModelLabel`, `faceLandmarksDetectorTrainingModelLabel`,
`faceBlendshapesDetectorTrainingModelLabel`, `passiveFaceTrainingModelLabel`, `faceMaskTrainingModelLabel`,
`focusFaceTrainingModelLabel`, `idCaptureTrainingModelLabel`, `docDetectionTrainingModelLabel`,
`fingerprintDetectionTrainingModelLabel`, `focusTrainingModelLabel`.

**Never reported by Medium:** `classifierTrainingModelLabel` — document classification runs on the server for
this flavour.

**States:** `ok`, `paused`, `downloading`, `downloaded`, `downloadingFromS3`, `downloadedFromS3`, `error`.

---

## Features

Every capture API follows the same two-phase shape:

1. **Capture** — present a flow from one of your view controllers and receive a result object.
2. **Submit** — call `finalSubmit` on that result to send it to the IDmission platform.

Splitting the two lets you review, gate, or annotate a capture before it leaves the device.

Each section below gives the exact public signature followed by a complete, runnable example — every
completion handler is written out in full.

---

### Live face check

Captures a selfie and runs passive liveness on the device.

```swift
public class func liveFaceCheck(
    from presenter: UIViewController,
    customerDataOptions: CommonCustomerDataRequest? = nil,
    options: AdditionalCustomerLiveCheckData? = nil,
    completion: @escaping LiveFaceCheckCompletion   // Result<LiveFaceCheckResult, Error>
)
```

```swift
import SelfieCaptureMedium

IDentitySDK.liveFaceCheck(
    from: self,
    customerDataOptions: CommonCustomerDataRequest(),
    options: AdditionalCustomerLiveCheckData()
) { result in
    switch result {
    case .success(let capture):
        // capture.selfie: Selfie, capture.isFakeFace: Bool\n        capture.finalSubmit { submission in
            switch submission {
            case .success(let response):
                print(response)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    case .failure(let error):
        print(error.localizedDescription)
    }
}
```

---

### ID validation

Captures and validates an identity document.

```swift
public class func idValidation(
    from presenter: UIViewController,
    customerDataOptions: CommonCustomerDataRequest? = nil,
    options: AdditionalCustomerWFlagCommonData,
    captureBack: CaptureBack = .auto,
    isSecondaryID: Bool = false,
    completion: @escaping ValidateIdCompletion       // Result<ValidateIdResult, Error>
)
```

```swift
import IDCaptureMedium

IDentitySDK.idValidation(
    from: self,
    customerDataOptions: CommonCustomerDataRequest(),
    options: AdditionalCustomerWFlagCommonData(),
    captureBack: .auto,          // .auto, .yes, or .no
    isSecondaryID: false
) { result in
    switch result {
    case .success(let capture):
        capture.finalSubmit { submission in
            switch submission {
            case .success(let response):
                print(response)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    case .failure(let error):
        print(error.localizedDescription)
    }
}
```

Use `captureBack: .auto` to let the SDK decide whether the document's back side is needed.

To skip the document-type picker, use the overload that takes an explicit document type:

```swift
public class func idValidation(
    from presenter: UIViewController,
    customerDataOptions: CommonCustomerDataRequest? = nil,
    options: AdditionalCustomerWFlagCommonData,
    idType: String,
    idCountry: String,
    idState: String?,
    isSecondaryID: Bool = false,
    completion: @escaping ValidateIdCompletion
)
```

```swift
IDentitySDK.idValidation(
    from: self,
    customerDataOptions: CommonCustomerDataRequest(),
    options: AdditionalCustomerWFlagCommonData(),
    idType: "PP",                // document type code, e.g. "PP" for passport
    idCountry: "USA",
    idState: "CA",               // optional — pass nil where a state does not apply
    isSecondaryID: false
) { result in
    switch result {
    case .success(let capture):
        capture.finalSubmit { submission in
            switch submission {
            case .success(let response):
                print(response)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    case .failure(let error):
        print(error.localizedDescription)
    }
}
```

---

### ID validation and face match

Captures the document **and** a selfie, then matches the selfie against the portrait printed on the document.

```swift
public class func idValidationAndMatchFace(
    from presenter: UIViewController,
    customerDataOptions: CommonCustomerDataRequest? = nil,
    options: AdditionalCustomerWFlagCommonData,
    captureBack: CaptureBack = .auto,
    isSecondaryID: Bool = false,
    completion: @escaping ValidateIdMatchFaceCompletion  // Result<ValidateIdMatchFaceResult, Error>
)
```

```swift
import SelfieCaptureMedium

IDentitySDK.idValidationAndMatchFace(
    from: self,
    customerDataOptions: CommonCustomerDataRequest(),
    options: AdditionalCustomerWFlagCommonData(),
    captureBack: .auto,
    isSecondaryID: false
) { result in
    switch result {
    case .success(let capture):
        // capture.selfie, capture.front, capture.back\n        capture.finalSubmit { submission in
            switch submission {
            case .success(let response):
                print(response)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    case .failure(let error):
        print(error.localizedDescription)
    }
}
```

The overload that skips the document-type picker:

```swift
public class func idValidationAndMatchFace(
    from presenter: UIViewController,
    customerDataOptions: CommonCustomerDataRequest? = nil,
    options: AdditionalCustomerWFlagCommonData,
    idType: String,
    idCountry: String,
    idState: String?,
    isSecondaryID: Bool = false,
    completion: @escaping ValidateIdMatchFaceCompletion
)
```

```swift
IDentitySDK.idValidationAndMatchFace(
    from: self,
    customerDataOptions: CommonCustomerDataRequest(),
    options: AdditionalCustomerWFlagCommonData(),
    idType: "PP",
    idCountry: "USA",
    idState: "CA",               // optional — pass nil where a state does not apply
    isSecondaryID: false
) { result in
    switch result {
    case .success(let capture):
        capture.finalSubmit { submission in
            switch submission {
            case .success(let response):
                print(response)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    case .failure(let error):
        print(error.localizedDescription)
    }
}
```

---

### ID validation and customer enrollment

Validates a document and enrolls the customer as a new record in one pass.

```swift
public class func idValidationAndCustomerEnroll(
    from presenter: UIViewController,
    customerDataOptions: CommonCustomerDataRequest? = nil,
    personalData: PersonalCustomerCommonRequestEnrollData,
    options: AdditionalCustomerWFlagCommonData,
    captureBack: CaptureBack = .auto,
    completion: @escaping ValidateIdCustomerEnrollCompletion  // Result<CustomerEnrollResult, Error>
)
```

```swift
import SelfieCaptureMedium

let personalData = PersonalCustomerCommonRequestEnrollData(uniqueNumber: "CUST-10432")

IDentitySDK.idValidationAndCustomerEnroll(
    from: self,
    customerDataOptions: CommonCustomerDataRequest(),
    personalData: personalData,
    options: AdditionalCustomerWFlagCommonData(),
    captureBack: .auto
) { result in
    switch result {
    case .success(let capture):
        capture.finalSubmit(cardToken: nil, cardLast4: nil) { submission in
            switch submission {
            case .success(let response):
                print(response)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    case .failure(let error):
        print(error.localizedDescription)
    }
}
```

> [!NOTE]
> `CustomerEnrollResult.finalSubmit` is the only submit that takes extra arguments — `cardToken` and
> `cardLast4`, both optional and both defaulting to `nil`.

The overload that skips the document-type picker:

```swift
public class func idValidationAndCustomerEnroll(
    from presenter: UIViewController,
    customerDataOptions: CommonCustomerDataRequest? = nil,
    personalData: PersonalCustomerCommonRequestEnrollData,
    options: AdditionalCustomerWFlagCommonData,
    idType: String,
    idCountry: String,
    idState: String?,
    completion: @escaping ValidateIdCustomerEnrollCompletion
)
```

```swift
IDentitySDK.idValidationAndCustomerEnroll(
    from: self,
    customerDataOptions: CommonCustomerDataRequest(),
    personalData: personalData,
    options: AdditionalCustomerWFlagCommonData(),
    idType: "PP",
    idCountry: "USA",
    idState: "CA"                // optional — pass nil where a state does not apply
) { result in
    switch result {
    case .success(let capture):
        capture.finalSubmit(cardToken: nil, cardLast4: nil) { submission in
            switch submission {
            case .success(let response):
                print(response)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    case .failure(let error):
        print(error.localizedDescription)
    }
}
```

---

### Enroll biometrics

Registers a customer's face so they can later be verified or identified.

```swift
public class func customerEnrollBiometrics(
    from presenter: UIViewController,
    customerDataOptions: CommonCustomerDataRequest? = nil,
    personalData: PersonalCustomerEnrollBiometricsRequestData,
    options: AdditionalCustomerEnrollBiometricRequestData,
    completion: @escaping CustomerEnrollBiometricsCompletion  // Result<CustomerEnrollBiometricsResult, Error>
)
```

```swift
import SelfieCaptureMedium

let personalData = PersonalCustomerEnrollBiometricsRequestData(uniqueNumber: "CUST-10432")

IDentitySDK.customerEnrollBiometrics(
    from: self,
    customerDataOptions: CommonCustomerDataRequest(),
    personalData: personalData,
    options: AdditionalCustomerEnrollBiometricRequestData()
) { result in
    switch result {
    case .success(let capture):
        capture.finalSubmit { submission in
            switch submission {
            case .success(let response):
                print(response)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    case .failure(let error):
        print(error.localizedDescription)
    }
}
```

`uniqueNumber` is the only required field on `PersonalCustomerEnrollBiometricsRequestData`; every other
field has a default.

---

### Customer verification

**1:1.** Confirms that the person in front of the camera is the customer they claim to be.

```swift
public class func customerVerification(
    from presenter: UIViewController,
    customerDataOptions: CommonCustomerDataRequest? = nil,
    personalData: PersonalCustomerVerifyData,
    options: AdditionalCustomerCommonData,
    completion: @escaping CustomerVerificationCompletion  // Result<CustomerVerificationResult, Error>
)
```

```swift
import SelfieCaptureMedium

IDentitySDK.customerVerification(
    from: self,
    customerDataOptions: CommonCustomerDataRequest(),
    personalData: PersonalCustomerVerifyData(uniqueNumber: "CUST-10432"),
    options: AdditionalCustomerCommonData()
) { result in
    switch result {
    case .success(let capture):
        capture.finalSubmit { submission in
            switch submission {
            case .success(let response):
                print(response)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    case .failure(let error):
        print(error.localizedDescription)
    }
}
```

---

### Identify customer

**1:N.** Finds an unknown person among the customers already enrolled. Takes no `personalData`, because the
customer is what you are trying to discover.

```swift
public class func identifyCustomer(
    from presenter: UIViewController,
    customerDataOptions: CommonCustomerDataRequest? = nil,
    options: AdditionalCustomerCommonData,
    completion: @escaping CustomerIdentifyCompletion  // Result<CustomerIdentifyResult, Error>
)
```

```swift
import SelfieCaptureMedium

IDentitySDK.identifyCustomer(
    from: self,
    customerDataOptions: CommonCustomerDataRequest(),
    options: AdditionalCustomerCommonData()
) { result in
    switch result {
    case .success(let capture):
        capture.finalSubmit { submission in
            switch submission {
            case .success(let response):
                print(response)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    case .failure(let error):
        print(error.localizedDescription)
    }
}
```

---

### Autofill

Reads a document **on the device** and hands you its parsed fields directly. There is no `finalSubmit` —
nothing is sent to the IDmission platform, which makes this the right call for pre-filling a form before the
customer commits.

```swift
public class func autofill(
    from presenter: UIViewController,
    captureIdSide: AutofillCaptureIdSide,
    completion: @escaping AutofillAPICompletion   // Result<CustomerAutofillResponse, Error>
)
```

```swift
import IDCaptureMedium

IDentitySDK.autofill(
    from: self,
    captureIdSide: .both          // .front, .back, or .both
) { result in
    switch result {
    case .success(let response):
        print(response)           // parsed document fields
    case .failure(let error):
        print(error.localizedDescription)
    }
}
```

---

### Signature capture

Requires the **`SignatureCaptureMediumSDK`** product. Returns a `SignatureDataRequest` rather than a submittable result —
assign it to `CommonCustomerDataRequest.signatureData` and submit it with a subsequent flow.

```swift
public class func signatureCapture(
    from presenter: UIViewController,
    completion: @escaping SignatureCaptureCompletion   // Result<SignatureDataRequest, Error>
)
```

```swift
import SignatureCaptureMedium

IDentitySDK.signatureCapture(from: self) { result in
    switch result {
    case .success(let signature):
        var customerData = CommonCustomerDataRequest()
        customerData.signatureData = signature
        // pass customerData into any capture API as customerDataOptions
    case .failure(let error):
        print(error.localizedDescription)
    }
}
```

---

### Voice capture

Requires the **`VoiceCaptureMediumSDK`** product, plus `NSMicrophoneUsageDescription` and
`NSSpeechRecognitionUsageDescription`. Returns a file `URL` for the recorded sample.

```swift
public class func voiceCapture(
    from presenter: UIViewController,
    completion: @escaping VoiceCaptureCompletion   // Result<URL, Error>
)
```

```swift
import VoiceCaptureMedium

IDentitySDK.voiceCapture(from: self) { result in
    switch result {
    case .success(let fileURL):
        print(fileURL)
    case .failure(let error):
        print(error.localizedDescription)
    }
}
```

---

### Fingerprint capture

Requires the **`FingerPrintCaptureMediumSDK`** product. Returns a `FingerPrintData` value.

```swift
public class func fingerPrintCapture(
    from presenter: UIViewController,
    completion: @escaping FingerPrintCaptureCompletion   // Result<FingerPrintData, Error>
)
```

```swift
import FingerPrintCaptureMedium

IDentitySDK.fingerPrintCapture(from: self) { result in
    switch result {
    case .success(let fingerPrintData):
        print(fingerPrintData)
    case .failure(let error):
        print(error.localizedDescription)
    }
}
```

---

### Generic final submit

Escape hatch for client-specific configurations that no dedicated API covers. You supply the request
dictionary and receive the raw response.

```swift
public class func genericApiCall(
    genericDataDictionary: [String: Any],
    completion: @escaping GenericAPICompletion   // Result<[String: Any], Error>
)
```

```swift
let genericDataDictionary: [String: Any] = [
    "key": "value"
]

IDentitySDK.genericApiCall(genericDataDictionary: genericDataDictionary) { result in
    switch result {
    case .success(let response):
        print(response)
    case .failure(let error):
        print(error.localizedDescription)
    }
}
```

---

`CommonCustomerDataRequest` and the various `Additional…Data` option structs carry the per-transaction
settings; every field has a default, so `AdditionalCustomerWFlagCommonData()` is a valid starting point.
The SDK builds the request XML for you — you never construct it by hand.
## ePassport NFC chip reading

Add the **`IDentityMediumNFC`** product to read the contactless chip in an ePassport or eID, recovering the
signed portrait and data groups and verifying passive and chip authentication.

### Enable the capability

1. In **Signing & Capabilities**, add **Near Field Communication Tag Reading**. Xcode writes:

   ```xml
   <key>com.apple.developer.nfc.readersession.formats</key>
   <array>
       <string>TAG</string>
   </array>
   ```

2. Declare the eMRTD application identifiers in your `Info.plist`:

   ```xml
   <key>com.apple.developer.nfc.readersession.iso7816.select-identifiers</key>
   <array>
       <string>A0000002471001</string>
       <string>A0000002472001</string>
       <string>00000000000000</string>
   </array>
   ```

3. Add `NFCReaderUsageDescription`.

### How it hooks up

Once the product is linked, the core SDK **discovers the NFC reader at runtime** — there is no registration
code to write. Document flows that support chip reading will use it automatically.

To drive a chip read yourself, the reader keys off the three MRZ fields:

```swift
import IDentityMediumNFC

let reader = NFCEntryPoint()
guard reader.readingAvailable else { return }   // false on devices without NFC

reader.readPassport(
    documentNumber: "L898902C3",
    dateOfBirth:    "740812",   // YYMMDD
    dateOfExpiry:   "120415",   // YYMMDD
    promptText:         "Hold your passport near the top of your iPhone.",
    readingDataText:    "Reading passport…",
    readingDataSuccessText: "Done",
    showProgress: true,
    readChunkSize: nil          // nil uses the SDK default
) { passport, error in
    guard let passport, error == nil else { return }
    print(passport.documentNumber, passport.PACEStatus, passport.passportCorrectlySigned)
}
```

NFC reading requires a physical iPhone 7 or later; it is unavailable in the simulator.

---

## Localization

The SDK ships English and Spanish UI strings.

Set it when you initialize:

```swift
IDentitySDK.initializeSDK(
    language: .es,
    isGPSEnabled: true,
    geolocationRequired: false,
    isUpdateModelsData: true,
    accessToken: accessToken
) { error in
    if let error {
        print("SDK init failed:", error.localizedDescription)
    } else {
        // Ready
    }
}
```

Or change it at any point afterwards:

```swift
Language.current = .es
```

`Language.none` disables the SDK's own string localization.

---

## Security controls

The SDK detects screenshots and screen recording, and scans loaded images for hooking and instrumentation
frameworks. Both protections are enabled by default once `initializeSDK` completes.

```swift
// Screenshot and screen-recording monitoring. Enabled by default after initializeSDK.
IDentitySDK.setScreenSecurityEnabled(true)

// The automatic blur overlay applied when screen recording is detected. Enabled by default.
IDentitySDK.isScreenRecordingEnabled(true)

// Names of your own security frameworks that would otherwise be flagged as
// instrumentation. Set this BEFORE calling initializeSDK.
IDentitySDK.allowedSecurityFrameworks = ["MyJailbreakDetector"]
```

> [!NOTE]
> Despite the `is` prefix, `isScreenRecordingEnabled(_:)` is a setter, not a query — it takes a `Bool` and
> returns nothing.

If your app bundles a legitimate anti-tamper or jailbreak-detection framework, add its name to
`allowedSecurityFrameworks` **before** initializing. The SDK's hook detection would otherwise flag it as a
false positive.

`setDevelopmentRelaxationSecret(_:)` relaxes selected runtime integrity checks for debugging. **Never ship an
app that calls it.** Ask IDmission support before using it.

---

## Diagnostics

```swift
IDentitySDK.version                        // SDK version string
IDentitySDK.isInitialized                  // Bool
IDentitySDK.modelVersions                  // [String: String] of on-device model versions
IDentitySDK.areModelsAlreadyDownloadedAndValid
IDentitySDK.requestID                      // unique id for the current request
```

Include `IDentitySDK.version` and `IDentitySDK.requestID` in any support ticket — they let IDmission trace a
transaction end to end.

---

## Framework sizes

Measured at **11.1.17**. Uncompressed on-disk size of the `arm64` device slice. **Not** App Store download size — thinning and
compression reduce the delivered figure substantially.

| Framework | Size | Included with |
|:---|---:|:---|
| `IDentityMediumSDK` | 25.9 MB | `IDentityMediumSDK` |
| `IDCaptureMedium` | 0.9 MB | `IDentityMediumSDK` |
| `SelfieCaptureMedium` | 1.1 MB | `IDentityMediumSDK` |
| `IDentityMediumModels` | 21.1 MB | `IDentityMediumModels` (optional) |
| `IDentityMediumNFC` | 4.2 MB | `IDentityMediumNFC` (optional) |
| `FingerPrintCaptureMedium` | 7.5 MB | `FingerPrintCaptureMediumSDK` (optional) |
| `SignatureCaptureMedium` | 0.3 MB | `SignatureCaptureMediumSDK` (optional) |
| `VoiceCaptureMedium` | 0.2 MB | `VoiceCaptureMediumSDK` (optional) |

Required products total **27.9 MB**; every optional product adds to that. Omit `IDentityMediumModels` to save
21.1 MB of app binary at the cost of a model download on first run.

---

## Versioning and releases

Releases are published as Git tags of the form `MAJOR.MINOR.PATCH` — for example `11.1.17`. Pin with
`from: "11.1.17"` to accept compatible updates, or pin `.exact("11.1.17")` if your release process requires a
frozen dependency graph.

The three IDmission SPM packages are versioned in lockstep. If you integrate more than one, use the same
version across all of them.

### Release notes

#### 11.1.17
- Added support for Swift Package Manager (SPM).
- Added Dynamic IDCapture functionality.

---

## Troubleshooting

| Symptom | Cause and fix |
|:---|:---|
| `no such module 'IDentityMediumSDK'` when building for the simulator on an Apple Silicon Mac | No `arm64` simulator slice. Build for a physical device, or set `EXCLUDED_ARCHS[sdk=iphonesimulator*] = arm64`. See [Apple Silicon simulators](#apple-silicon-simulators). |
| `Library not loaded: @rpath/IDentityMediumSDK.framework/…` at launch | The binary target is not embedded. Confirm the product appears under **General → Frameworks, Libraries, and Embedded Content** with **Embed & Sign**. |
| Capture screens present, but every submission fails | The SDK was not initialized, or the access token has expired. Check `IDentitySDK.isInitialized` and mint a fresh token. |
| Initialization never completes | A model stage is stuck. Log every `updateInitialization` callback and check network access to the IDmission model CDN. |
| Camera view is black | Missing `NSCameraUsageDescription`, or camera permission was denied in Settings. |
| NFC reading is unavailable | Missing NFC capability, entitlement, or `select-identifiers`; running on the simulator; or the device predates iPhone 7. |
| App Store upload rejected for an invalid bundle | Ensure only the products you use are linked, and that they are embedded and signed rather than merely linked. |
| Duplicate symbols with TensorFlow Lite or MLKit | You added the CocoaPods dependencies from the older integration guide. The Swift Package needs none — remove them. |

---

## Support

| | |
|:---|:---|
| Technical support | <support@idmission.com> |
| Sales and licensing | <sales@idmission.com> |
| Privacy | <privacyteam@idmission.com> |
| Web | <https://www.idmission.com> |

Sample application: [MediumSDK2Sample](https://github.com/Idmission-LLC/MediumSDK2Sample)

When reporting an issue, include your SDK version, iOS version, device model, the `requestID` of a failing
transaction, and the `updateInitialization` log if the problem occurs at startup.

---

## Licence

Copyright © 2026 IDmission, LLC. All rights reserved.

Proprietary and confidential. Use requires a written commercial agreement with IDmission. See
[LICENSE](LICENSE) for the full terms, including the third-party open-source notices that apply to components
embedded in the SDK.
