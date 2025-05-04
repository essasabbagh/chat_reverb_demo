const String publicChannelName = 'messages';
const eventName = 'App\\Events\\MessageSent';

const String host = '192.168.1.5'; // Your Mac's local IP
const String baseUrl = 'http://10.0.2.2:8000/api';
const String broadcastingUrl = 'http://10.0.2.2:8000/api/broadcasting/auth';

// const String host = '192.168.1.5'; // Your Mac's local IP
// const String baseUrl = 'http://127.0.0.1:8000/api';
// const String broadcastingUrl = 'http://127.0.0.1:8000/api/broadcasting/auth';

// const String host = '2e55-2a02-ff0-23e-2632-fc7d-704c-3d70-bb0a.ngrok-free.app';
// const String baseUrl = 'https://2e55-2a02-ff0-23e-2632-fc7d-704c-3d70-bb0a.ngrok-free.app/api';
// const String broadcastingUrl = 'https://2e55-2a02-ff0-23e-2632-fc7d-704c-3d70-bb0a.ngrok-free.app/api/broadcasting/auth';

// const String host = 'localhost';
// const String baseUrl = 'http://chat_app.test/api';
// const String broadcastingUrl = 'http://chat_app.test/api/broadcasting/auth';

// php artisan reverb:start --host="0.0.0.0" --port=8080 --hostname="chat_app.test"
// php artisan reverb:start --host="0.0.0.0" --port=8000 --hostname="192.168.1.5"

const String key = 'vvi9foswtexagmutenwt';
const int port = 8080; // WebSocket port
const String scheme = 'ws'; // 'ws' for non-secure connections

