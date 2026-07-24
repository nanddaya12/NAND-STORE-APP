# Security Guide

This document lists developer and operational security guidelines configured in the **NAND Store** application.

## 1. Input Sanitization & Forms Protection
*   All user input forms use `InputValidators` class callbacks to match patterns for Emails, Card numbers, CVV lengths, Phone digits, and passwords.
*   **Credit Card Validation**: Implements the Luhn algorithm locally to reject typos before hitting database registers.

## 2. API Request Signature Check
*   Outgoing HTTP requests are signed cryptographically using HMAC-SHA256 HMAC protocols.
*   Headers contain Nonce, timestamp, and unique request ID fields to intercept replay attacks.

## 3. Local Platform Checks
*   `DeviceSecurity` intercepts emulator environments, warning administrators of developer builds.
*   Biometric FaceID/Fingerprint local validations check user access credentials on demand.
