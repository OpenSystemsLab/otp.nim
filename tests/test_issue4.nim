import otp
var totp = Totp.init("GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ")
assert totp.at(1111111111) == 50471
assert totp.at(1234567890) == 5924
assert totp.at(2000000000) == 279037

assert totp.verify(50471, 1111111111)
let token = totp.now()
assert totp.verify(token)
