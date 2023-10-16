# Liquidity iOS App

## Tooling
- iOS 15.0 +
- Xcode 13 +
- Swift 5.0 +
- Packages

## UnitTest
How to setup run the UnitTest!
Set up the mock framework Sourcery [https://github.com/krzysztofzablocki/Sourcery] for writing unit tests (UT).
    1. Select the target for which you need to write UT.
    2. Create a file .sourcery.yml in the target where you need to generate mock data. It is a hidden file that you can also copy from the files that I have created before
    3. Edit the file gen-mocks.sh; you need to add the target where UT should be run as a source. You just add the same as the existing syntax I created earlier
    4. Run the batch script [gen-mocks.sh] located in the BuildScripts folder. (Run [chmod +x gen-mocks.sh] and [./gen-mocks.sh])
If you run it for the first time, please do all 4 steps
Next time you just need just run [./gen-mocks.sh]
From xcode 14 You can trigger the command plugin from the contextual menu.

## Testing
For the ease of development, Liquidty Platform offers you two modes:

- `Test`: Test credentials and real-life like data. Requests made to the Test environment will never hit banking or payments or identity verification networks. These will never affect live data.

- `Live`: Real credentials and real data. Requests made to the Live environment will hit Live environments of banking or payments or identity verification networks. These will hit live data.

## AppStore reviews
We are providing Apple reviewers a special phone number to sign in into the app without neededing to receive an SMS. To do so, the app manually checks if the input number is `+12058583181`, and if it is, it will hit Twillio's API to read the messages itself. More info on `TwilioMFA` class.
