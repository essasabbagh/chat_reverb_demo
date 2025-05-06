
## Test local (Mac) - web (chrome)

run flutter app web (use vscode to run another client)

```bash 
flutter run -d chrome   

```

const file should be 

```dart 
const String publicChannelName = 'messages';
const eventName = 'App\\Events\\MessageSent';
const String key = 'vvi9foswtexagmutenwt';
const int port = 8080; // WebSocket port
const String scheme = 'ws'; // 'ws' for non-secure connections

const String host = 'chat_app.test';
const String baseUrl = 'http://chat_app.test/api';
const String broadcastingUrl = 'http://chat_app.test/api/broadcasting/auth';

```

in laravel should be run reverb server

```bash
php artisan serv 
php artisan reverb:start --host="0.0.0.0" --port=8080 --hostname="chat_app.test" --debug  
```
---

## on android

```bash 
adb devices
# List of devices attached
# emulator-5554   device
# emulator-5556   device
```
run on another device
```bash 
flutter run -d emulator-5556
```

const file should be 

```dart 
const String publicChannelName = 'messages';
const eventName = 'App\\Events\\MessageSent';
const String key = 'vvi9foswtexagmutenwt';
const int port = 8080; // WebSocket port
const String scheme = 'ws'; // 'ws' for non-secure connections

const String host = '10.0.2.2';
const String baseUrl = 'http://10.0.2.2:8000/api';
const String broadcastingUrl = 'http://10.0.2.2:8000/api/broadcasting/auth';

```
in laravel should be run reverb server

```bash
php artisan serv 
php artisan reverb:start --host=127.0.0.1 --port=8080 --debug
```
or 
```bash
php artisan serv 
php artisan reverb:start --debug
```


env file for reverb 

```properties
BROADCAST_CONNECTION=reverb
# BROADCAST_DRIVER=reverb

REVERB_APP_ID=598558
REVERB_APP_KEY=vvi9foswtexagmutenwt
REVERB_APP_SECRET=7wqenqudmgpvrkekytq4
REVERB_SERVER_HOST=0.0.0.0
REVERB_SERVER_PORT=8080 # Internal Reverb server port
REVERB_SCHEME=http
REVERB_HOST="chat_app.test"
# REVERB_HOST=ws.laravel.com
REVERB_PORT=8080
# REVERB_PORT=443
```


help links
https://pub.dev/packages/dart_pusher_channels

https://github.com/laravel/framework/discussions/51766#discussioncomment-10714044

https://stackoverflow.com/questions/79178936/laravel-reverb-and-flutter-chat-app-not-working

