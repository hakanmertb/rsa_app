import 'dart:math';
import 'package:flutter/material.dart';

class RSAService {
  late final int p, q, n, phi, e, d;

  RSAService() {
    generateKeys();
  }

  bool isPrime(int number) {
    if (number < 2) return false;
    for (int i = 2; i <= sqrt(number).toInt(); i++) {
      if (number % i == 0) return false;
    }
    return true;
  }

  int generatePrime(int min, int max) {
    Random random = Random();
    int prime;
    do {
      prime = min + random.nextInt(max - min + 1);
    } while (!isPrime(prime));
    return prime;
  }

  void generateKeys() {
    p = generatePrime(100, 500);
    do {
      q = generatePrime(100, 500);
    } while (q == p);

    n = p * q;
    phi = (p - 1) * (q - 1);

    e = chooseE(phi);
    d = modInverse(e, phi);

    debugPrint("Asal Sayılar: p = $p, q = $q");
    debugPrint("Public Key: (e=$e, n=$n)");
    debugPrint("Private Key: (d=$d, n=$n)");
  }

  int chooseE(int phi) {
    for (int i = 3; i < phi; i++) {
      if (gcd(i, phi) == 1) {
        return i;
      }
    }
    throw Exception("Uygun e değeri bulunamadı.");
  }

  int gcd(int a, int b) {
    while (b != 0) {
      int temp = b;
      b = a % b;
      a = temp;
    }
    return a;
  }

  int modInverse(int a, int m) {
    for (int x = 1; x < m; x++) {
      if ((a * x) % m == 1) {
        return x;
      }
    }
    throw Exception("Modüler ters bulunamadı.");
  }

  int modPow(int base, int exponent, int modulus) {
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
      int c = modPow(m, e, n);
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
      int m = modPow(c, d, n);
      decrypted += String.fromCharCode(m);
    }
    return decrypted;
  }

  // Public key getter
  Map<String, int> get publicKey => {'e': e, 'n': n};

  // Private key getter
  Map<String, int> get privateKey => {'d': d, 'n': n};
}
