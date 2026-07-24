# Encryption Guide

This document lists the cryptographic standards and data protection protocols implemented in the **NAND Store** application.

## 1. AES-256 Symmetric Encryption
*   **Target**: Local storage Hive database boxes containing sensitive data (`cart`, `users`, `orders`).
*   **Key Source**: Generated cryptographically on first boot utilizing a secure entropy pool, stored in the platform Keychain/Keystore via `SecureStorageService`.
*   **Cipher Configuration**: Hive blocks are initialized with `HiveAesCipher` using the securely retrieved 256-bit key.

## 2. SHA-256 Hash Algorithm
*   Used for generating cryptographic validation signatures inside the `RequestSigner` header generation blocks.
*   Enforces request payload checks, preventing payload tampering in transit.
