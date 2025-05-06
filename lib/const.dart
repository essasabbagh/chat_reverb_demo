const String publicChannelName = 'messages';
const eventName = 'App\\Events\\MessageSent';
const String key = 'vvi9foswtexagmutenwt';
const int port = 8080; // WebSocket port
const String scheme = 'ws'; // 'ws' for non-secure connections

/// For local development, web (chrom)
// const String host = '127.0.0.1'; // Your Mac's local IP
// const String baseUrl = 'http://127.0.0.1:8000/api';
// const String broadcastingUrl = '$baseUrl/broadcasting/auth';

// for mac local development
// const String host = 'chat_app.test';
// const String baseUrl = 'http://chat_app.test/api';
// const String broadcastingUrl = '$baseUrl/broadcasting/auth';

/// For local development, Android Emulator
const String host = '10.0.2.2';
const String baseUrl = 'http://10.0.2.2:8000/api';
const String broadcastingUrl = '$baseUrl/broadcasting/auth';