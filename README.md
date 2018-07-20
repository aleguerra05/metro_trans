# MetroTrans
Transacction viewer for Transfermovil cuban app

## Download Android App
[MetroTrans](https://github.com/aleguerra05/metro_trans/releases/download/0.6-beta/app-release.apk)

## Snapshots

<img src="https://github.com/aleguerra05/metro_trans/blob/master/screenshots/Screenshot_1.png" alt="Snapshot 1" width="200px"/>
<img src="https://github.com/aleguerra05/metro_trans/blob/master/screenshots/Screenshot_2.png" alt="Snapshot 2" width="200px"/>

## Getting Started

Feel free to contribute, clone, pull request, issues, ...

## Thanks

Special thanks to:
- Flutter SMS developers (This is an SMS library for flutter.)
- simple_permissions plugin developer
- call_number plugin developer

## RoadMap

- [x] Adding travis-ci automatic build
- [ ] Execute USSD codes from SIM 1 or 2
- [ ] Graph with account balance
- [x] Support for 2 accounts (CUP & CUC)
- [ ] Improve Transactions Details
- [ ] Allow receive sms and auto-update transaction list
- [ ] Improve connect/disconnect button based on sms messages history
- [ ] Save/Load transaction data from database therefore sms messages
- [ ] Support another types of Bank Accounts (BANDEC,BPA)

## Bugs

- [x] Write External Storage access deny
- [x] Update balance USSD code dosen't works
- [ ] First run request SMS access and after that does not refresh transactions list
- [ ] Transaction list is unsorted
