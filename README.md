# otp.nim

This module implements One Time Password library for Nim.


Installation
============

    $ nimble install otp

Changes
=======

    0.1.1 - initial release

Usage
=====
```nim
import otp

let htop = newHotp("S3cret")
assert hotp.at(0) == 755224
assert hotp.at(1) == 287082

assert htop.verify(755224, 0) == true

echo hotp.provisioning_uri("mark@percival")

var totp = newTotp("GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ")
assert totp.at(1111111111) == 50471
assert totp.at(1234567890) == 5924
assert totp.at(2000000000) == 279037

totp = newTotp("blahblah")
echo totp.now()
```
