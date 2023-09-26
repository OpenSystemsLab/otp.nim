import otp

var hotp = Hotp.init("GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ")
assert hotp.at(0) == 755224
assert hotp.at(1) == 287082
assert hotp.at(2) == 359152
assert hotp.at(3) == 969429
assert hotp.at(4) == 338314
assert hotp.at(5) == 254676
assert hotp.at(6) == 287922
assert hotp.at(7) == 162583
assert hotp.at(8) == 399871
assert hotp.at(9) == 520489


assert hotp.verify(520489, 9) == true
assert hotp.verify(520489, 10) == false

#hotp = newHotp("wrn3pqx5uqxqvnqr")
#assert hotp.provisioningUri("mark@percival") == "otpauth://hotp/mark@percival?secret=wrn3pqx5uqxqvnqr&counter=0"


var totp = Totp.init("GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ")
assert totp.at(1111111111) == 50471
assert totp.at(1234567890) == 5924
assert totp.at(2000000000) == 279037


totp = Totp.init("wrn3pqx5uqxqvnqr")
assert totp.at(1297553958) == 102705

totp = Totp.init("blahblah")
echo totp.now()
