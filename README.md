# Liquidity iOS App
- Welcome to the Liquidity iOS repository. This is the main repository for Liquidity iOS application.

## Platfrom
- iOS 15.0 +
- Swift 5.0 +

## Required Tools Installation
- Xcode 14 + [https://developer.apple.com/download/more/]
- swiftlint 0.53.0: Laundry List [https://github.com/realm/SwiftLint/releases/tag/0.53.0]

## How to Run the Project
    1.Ensure that all the necessary tools are installed.
    2.Open the LiquidityFinancial.xcodeproj file.
    3.Please wait for Xcode to automatically synchronize all dependencies. When this process is complete, you will no longer see the spinning circle, and the status will be "running" in the tab bar at the top.

## How to Set Up Mock Class Generation and Run Unit Tests
Here's how to set up and run unit tests using the mock framework Sourcery [https://github.com/krzysztofzablocki/Sourcery]:
    1. Select the target for which you want to write unit tests (UT).
    2. Create a file named .sourcery.yml in the target where you intend to generate mock data. This file is hidden, and you can also copy it from the pre-existing files I've created.
    3. Edit the gen-mocks.sh file; you need to add the target where UT should be executed as a source. Simply follow the same syntax I've previously established.
    4. Run the batch script [gen-mocks.sh] located in the BuildScripts folder. First, make it executable with the command [chmod +x gen-mocks.sh], and then run it with [./gen-mocks.sh].
    5. After having mock data, they continue to run unitest as normal
If you're running this process for the first time, please follow all four steps. In subsequent runs, you can simply execute [./gen-mocks.sh].
Starting from Xcode 14, you can trigger the command plugin from the contextual menu.

## Integration Testing 
For the ease of development, Liquidty Platform offers you two modes:
- https://liquidity-cc.atlassian.net/wiki/spaces/ENGINEER/pages/32440322/Test+account+for+all+of+the+Applications

- `Test`: Test credentials and real-life like data. Requests made to the Test environment will never hit banking or payments or identity verification networks. These will never affect live data.

- `Live`: Real credentials and real data. Requests made to the Live environment will hit Live environments of banking or payments or identity verification networks. These will hit live data.

## Helpful links
- [How we work in Liquidity](https://liquidity-cc.atlassian.net/wiki/spaces/ENGINEER/pages/63307797/How+we+work+in+Liquidity)
- [Business documents](https://liquidity-cc.atlassian.net/wiki/spaces/ENGINEER/pages/66682883/Business+documents)

## AppStore reviews
We are providing Apple reviewers a special phone number to sign in into the app without neededing to receive an SMS. To do so, the app manually checks if the input number is `+12058583181`, and if it is, it will hit Twillio's API to read the messages itself. More info on `TwilioMFA` class.
