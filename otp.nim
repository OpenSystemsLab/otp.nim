#
#          Nim's Unofficial Library
#        (c) Copyright 2015 Huy Doan
#
#    See the file "LICENSE", included in this
#    distribution, for details about the copyright.
#

## This module implements One Time Password library

from hmac import hmac_sha1
from base32 import decode
from sha1 import toHex
from math import pow
from times import epochTime

const
  VERSION* = '0.1.1'

type
  OneTimePassword = ref object of RootObj
    digits: int
    secret: string

  HOTP = ref object of OneTimePassword
  TOTP = ref object of OneTimePassword
    interval: int


proc newHotp*(secret: string, digits: int = 6): HOTP =
  new(result)
  result.secret = secret
  result.digits = digits

proc newTotp*(secret: string, digits: int = 6, interval: int = 30): TOTP =
  new(result)
  result.secret = secret
  result.digits = digits
  result.interval = interval

proc int_to_bytestring(input: int, padding: int = 8): string =
  var input = input

  var arr: seq[char] = @[]
  while input != 0:
    arr.add(char(input and 0xFF))
    input = input shr 8

  while arr.len < padding:
    arr.add('\0')

  result = newString(arr.len)
  for i in 0..arr.len-1:
    result[i] = arr[arr.len - i - 1]

proc timecode(self: TOTP, timestamp: int): int =
  result = int(timestamp / self.interval)

proc generate(self: OneTimePassword, input: int): int =
  var hmac_hash = hmac_sha1(base32.decode(self.secret), int_to_bytestring(input))

  let offset = hmac_hash[19].int and 0xf
  let code = (hmac_hash[offset].int and 0x7f) shl 24 or
             (hmac_hash[offset + 1].int and 0xff) shl 16 or
             (hmac_hash[offset + 2].int and 0xff) shl 8 or
             (hmac_hash[offset + 3].int and 0xff)

  result = code mod pow(10.0, self.digits.float).int


proc at*(self: HOTP, count: int): int =
  return self.generate(count)

proc at*(self: TOTP, timestamp: int): int =
  return self.generate(self.timecode(timestamp))

proc now*(self: TOTP): int =
  result = self.at(epochTime().int)

proc verify*(self: HOTP, otp: int, counter: int = 0): bool =
  otp == self.at(counter)

proc verify*(self: TOTP, otp: int, timestamp: int = 0): bool =
  if timestamp == 0:
    var timestamp = epochTime().int
  otp == self.at(timestamp)


proc provisioningUri*(self: OneTimePassword, name: string, initialCount: int = 0, issuerName: string = ""): string =
    var  otpType: string

    if self of HOTP:
      otpType = "htop"
    else:
      otpType = "totp"

    var base = "otpauth://" & otpType & "/"

    if issuerName != "":
      base &= issuerName & ":"

    result = base & name & "?secret=" & self.secret

    if self of HOTP:
      result &= "&counter=" & $initialCount

    if issuerName != "":
      result &= "&issuer=" & issuerName
