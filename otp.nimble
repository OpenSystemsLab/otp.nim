[Package]
name          = "otp"
version       = "0.3.0"
author        = "Huy Doan"
description   = "One Time Password library for Nim"
license       = "MIT"
skipDirs      = @["tests"]

[Deps]
Requires: "nim >= 1.6.10"
Requires: "hmac >= 0.3.1"
Requires: "base32 >= 0.1.3"
