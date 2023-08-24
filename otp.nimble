[Package]
name          = "otp"
version       = "0.2.1"
author        = "Huy Doan"
description   = "One Time Password library for Nim"
license       = "MIT"
skipDirs      = @["tests"]

[Deps]
Requires: "nim >= 1.6.10"
Requires: "hmac >= 0.3.1"
Requires: "base32"
