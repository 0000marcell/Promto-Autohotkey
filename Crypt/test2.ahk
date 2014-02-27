#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#Include Crypt.ahk
#Include CryptConst.ahk
#Include CryptFoos.ahk
hash := Crypt.Encrypt.StrEncrypt("MS encryption works in that way","007",5,1) ; encrypts string using AES_128 encryption and MD5 hash

msgbox % hash

decrypted_string := Crypt.Encrypt.StrDecrypt(hash, "007", 5, 1)

msgbox % decrypted_string ; decrypts the string using previously generated hash,AES_128 and MD5
