# ArtTime
  This is a tool for artists to have a simple and fast art challenges check.

### Links
[Demo Video](https://drive.google.com/file/d/1xOI-6wDHJKVjoY3q6UrApmSk-zeVBuDj/view?usp=sharing)

[Architecture plan](https://docs.google.com/document/d/1k_1PqAUoFySXglAQPxSd_lbAT05p0hmp/edit?usp=sharing&ouid=109211413724207780415&rtpof=true&sd=true)

### Plan (What to expect from this project):
- [x] Android app
  - [x] Scrollable calendar of uploaded challenges
  - [x] Detailed descriptions of challenges
  - [x] Page for adding challenges
- [x] Server 
  
### Further Development:
- [ ] Tagged challenges
- [ ] Lists of favourites
- [ ] Notifications
- [ ] Users' intercommunication (?)
- [ ] Personal calendars
- [ ] Server HTTPS and better Authorization
- [ ] Persistent storage on server side (currently if server is stopped all data will be lost)

### How to start
#### Prerequisites
1. Rust installed (tested with `rustc` 1.54.0)
2. Flutter and Android dev tools installed (tested with 2.5.1)
3. Dart is installed (tested with 2.14.2)   
4. You have an Android phone
5. Android phone is connected to the development laptop
6. USB debugging is enabled on phone
7. You have approved connection to this laptop for development

#### Starting
Start server:
```
cd arttime_server
cargo run
```

Find out the IP of the machine on which you will be starting the server.

Update `./arttime/lib/api.dart` `address` constant to match your machine's IP.

**Important**: for the local setup ensure both your phone and laptop are connected to the same wifi local network.

Start android app:

From IDE:
 - Open android app either from Android Studio or VS Code (appropriate Flutter plugins need to be installed)
 - VS Code: Click `Run` on top of `main` function
 - Android Studio: Click green arrow button

From console:
```
flutter run lib/main.dart
```

#### Run tests
Rust:
```
cd arttime_server
cargo test
```

Flutter/Dart:
```
cd arttime
flutter test -r expanded
```