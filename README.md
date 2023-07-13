# Liquidity iOS App

## Tooling
- iOS 15.0 +
- Xcode 13 +
- Swift 5.0 +
- Packages

## Testing
For the ease of development, Liquidty Platform offers you two modes:

- `Test`: Test credentials and real-life like data. Requests made to the Test environment will never hit banking or payments or identity verification networks. These will never affect live data.

- `Live`: Real credentials and real data. Requests made to the Live environment will hit Live environments of banking or payments or identity verification networks. These will hit live data.

## AppStore reviews
We are providing Apple reviewers a special phone number to sign in into the app without neededing to receive an SMS. To do so, the app manually checks if the input number is `+12058583181`, and if it is, it will hit Twillio's API to read the messages itself. More info on `TwilioMFA` class.
