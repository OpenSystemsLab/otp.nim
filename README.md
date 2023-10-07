# otp.nim [![build](https://github.com/OpenSystemsLab/otp.nim/actions/workflows/action.yaml/badge.svg)](https://github.com/OpenSystemsLab/otp.nim/actions/workflows/action.yaml)

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

let htop = Hotp.init("S3cret")
assert hotp.at(0) == 755224
assert hotp.at(1) == 287082

assert htop.verify(755224, 0) == true

echo hotp.provisioning_uri("mark@percival")

var totp = Totp.init("GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ")
assert totp.at(1111111111) == 50471
assert totp.at(1234567890) == 5924
assert totp.at(2000000000) == 279037

totp = Totp.init("blahblah")
echo totp.now()
```

This library uses the wonderful [stack_strings](https://github.com/termermc/nim-stack-strings) library for secrets.
Meaning secrets are fixed length one can use `--otp.secretSize:50` to override the size.
By default the secret length is 128 bytes.
Due to this the best way to handle secrets is as follows:
```nim
let mySecret = "S3cret"
if mySecret.len < secretSize:
  let hotp = Hotp.init(mySecret)
  assert hotp.at(0) == 755224
else:
  # Do something errory here
  raise (ref ValueError)(msg: "Secret size too large")
```
