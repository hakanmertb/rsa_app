class RSAService {
  late int p, q, n, phi, e, d;

  RSAService() {
    _generateKeys();
  }

  void _generateKeys() {
    p = 61;
    q = 53;
    n = p * q;
    phi = (p - 1) * (q - 1);
    e = 17;
    d = _modInverse(e, phi);
  }

  int _modInverse(int a, int m) {
    a = a % m;
    for (int x = 1; x < m; x++) {
      if ((a * x) % m == 1) {
        return x;
      }
    }
    return 1;
  }

  int _modPow(int base, int exponent, int modulus) {
    if (modulus == 1) return 0;
    int result = 1;
    base = base % modulus;
    while (exponent > 0) {
      if (exponent % 2 == 1) {
        result = (result * base) % modulus;
      }
      exponent = exponent >> 1;
      base = (base * base) % modulus;
    }
    return result;
  }

  String encrypt(String plaintext) {
    List<int> encrypted = [];
    for (int i = 0; i < plaintext.length; i++) {
      int m = plaintext.codeUnitAt(i);
      int c = _modPow(m, e, n);
      encrypted.add(c);
    }
    return encrypted.join(',');
  }

  String decrypt(String ciphertext) {
    List<int> encrypted =
        ciphertext.split(',').map((e) => int.parse(e)).toList();
    String decrypted = '';
    for (int i = 0; i < encrypted.length; i++) {
      int c = encrypted[i];
      int m = _modPow(c, d, n);
      decrypted += String.fromCharCode(m);
    }
    return decrypted;
  }
}
