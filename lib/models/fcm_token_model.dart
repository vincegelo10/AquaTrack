class FCMToken {
  String token;

  FCMToken(this.token);

  get fcmToken {
    return '${token}\n';
  }
}
