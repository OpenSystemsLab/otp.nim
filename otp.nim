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
from math import pow
from times import epochTime
import stack_strings as stackstrings

const secretSize* {.intDefine: "otp.secretSize".} = 128

type
  OneTimePasswordDefect = object of Defect
  OneTimePassword = object of RootObj
    digits: int
    secret: StackString[secretSize]

  HOTP* = object of OneTimePassword
  TOTP* = object of OneTimePassword
    interval: int

const 
  hookStr = "For security reasons a copy should not be made, this keeps the secret in memory longer."
  sizeErrStr = "Secret is too long, only secrets upto the following length are allowed: " & $secretSize

when NimMajor >= 2:
  proc `=dup`(_: HOTP): HOTP {.error: hookStr.}
  proc `=dup`(_: TOTP): TOTP {.error: hookStr.}
  
proc `=copy`(a: var HOTP, b: HOTP){.error: hookStr}
proc `=copy`(a: var TOTP, b: TOTP){.error: hookStr}

proc init*(_: typedesc[HOTP], secret: static openArray[char], digits: int = 6): HOTP =
  when secret.len > secretSize:
    {.error: "Secret length too long, consider using `-d:otp.secretSize` to increase it.".}
  result = HOTP(digits: digits)
  result.secret.add secret

proc init*(_: typedesc[HOTP], secret: openArray[char], digits: int = 6): HOTP =
  if secret.len > secretSize:
    raise (ref OneTimePasswordDefect)(msg: sizeErrStr)
  result = HOTP(digits: digits)
  result.secret.add secret

proc init*(_: typedesc[TOTP], secret: static openArray[char], digits: int = 6, interval: int = 30): TOTP =
  when secret.len > secretSize:
    {.error: "Secret length too long, consider using `-d:otp.secretSize` to increase it.".}
  result = TOTP(digits: digits, interval: interval)
  result.secret.add secret

proc init*(_: typedesc[TOTP], secret: openArray[char], digits: int = 6, interval: int = 30): TOTP =
  if secret.len > secretSize:
    raise (ref OneTimePasswordDefect)(msg: sizeErrStr)
  result = TOTP(digits: digits, interval: interval)
  result.secret.add secret

proc ensureWeCanCompile() {.used, gensym.} =
  discard TOTP.init("")
  discard HOTP.init("")

proc int_to_bytestring(input: int, padding: int = 8): string {.inline.} =
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

proc timecode(self: TOTP, timestamp: int): int {.inline.} =
  result = int(timestamp / self.interval)

proc generate(self: OneTimePassword, input: int): int {.inline.} =
  var hmac_hash = hmac_sha1(base32.decode(self.secret.toOpenArray()), int_to_bytestring(input))

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
  var timestamp = if timestamp == 0: epochTime().int else: timestamp
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

    result = base & name & "?secret=" & $self.secret

    if self of HOTP:
      result &= "&counter=" & $initialCount

    if issuerName != "":
      result &= "&issuer=" & issuerName
