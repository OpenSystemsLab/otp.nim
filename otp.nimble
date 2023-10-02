[Package]
name          = "otp"
version       = "0.3.3"
author        = "Huy Doan"
description   = "One Time Password library for Nim"
license       = "MIT"
skipDirs      = @["tests"]

[Deps]
Requires: "nim >= 1.6.14"
Requires: "hmac >= 0.3.1"
Requires: "base32 >= 0.1.3"
Requires: "stack_strings >= 1.1.3"
