{
    --------------------------------------------
    Filename: ST25DVXX-Demo.spin
    Author: Jesse Burt
    Description: Demo of the ST25DVXX driver
    Copyright (c) 2023
    Started Mar 28, 2023
    Updated Apr 1, 2023
    See end of file for terms of use.
    --------------------------------------------
}

CON

    _clkmode    = cfg#_clkmode
    _xinfreq    = cfg#_xinfreq

' -- User-defined constants
    SER_BAUD    = 115_200
    LED         = cfg#LED1

    I2C_SCL     = 24
    I2C_SDA     = 25
    I2C_FREQ    = 1_000_000                     ' max is 1_000_000
' --

OBJ

    cfg:    "boardcfg.flip"
    ser:    "com.serial.terminal.ansi"
    time:   "time"
    nfc:    "id.nfc.st25dvxx"

VAR

    byte _ee[nfc#ST25_EE_MAX_SZ]                ' accomodate up to 64kbit EEPROMs (ST25DV64K)

DAT

    { password to open I2C security session - factory default is all 0's }
    _pw byte $00, $00, $00, $00, $00, $00, $00, $00

PUB main{} | uid[2], rfa

    setup{}

    { status returned by i2c_present_passwd():
        0: success
        -1: validation failed (wrong password, or low-level write failed) }
    ser.printf1(@"I2C present password status: %d\n\r", nfc.i2c_present_passwd(@_pw))

    nfc.serial_num(@uid)

    ser.printf1(@"I2C security session open? %s\n\r", true_false(nfc.i2c_security_sess_open{}))
    ser.printf1(@"DC supply voltage detected? %s\n\r", true_false(nfc.vcc_detected{}))
    ser.printf1(@"RF field detected? %s\n\r", true_false(nfc.rf_field_detected{}))
    ser.printf1(@"Energy harvesting enabled? %s\n\r", true_false(nfc.energy_harvest_ena(-2)))
    ser.printf1(@"mem size (bytes): %d\n\r", nfc.capacity{})
    ser.printf2(@"UID: %08.8x%08.8x\n\r", uid[1], uid[0])
    ser.printf1(@"IC revision: %d\n\r", nfc.revision{})
    ser.printf1(@"AFI ID: %x\n\r", nfc.app_fam_id{})
    ser.printf1(@"DSF ID: %x\n\r", nfc.data_storage_fmt_id{})
    ser.printf1(@"AFI locked? %s\n\r", true_false(nfc.app_fam_id_locked{}))
    ser.printf1(@"DSFID locked? %s\n\r", true_false(nfc.data_storage_fmt_id_locked{}))
    ser.printf1(@"config locked? %s\n\r", true_false(nfc.config_locked{}))
    ser.printf1(@"block 0 WP? %s\n\r", true_false(nfc.blk0_write_protected{}))
    ser.printf1(@"block 1 WP? %s\n\r", true_false(nfc.blk1_write_protected{}))

    repeat rfa from 1 to 4
        ser.printf2(@"RF area %d R/W policy: %02.2b\n\r", rfa, nfc.rf_area_rw_policy(rfa))
        ser.printf2(@"RF area %d password policy: %02.2b\n\r", rfa, nfc.rf_area_pwd_policy(rfa))

    { show the first 512 bytes of the ST25's EEPROM }
    nfc.rd_block_lsbf(@_ee, 0, 512)
    ser.hexdump(@_ee, 0, 4, 512, 16)
    repeat

PUB true_false(val): tf
' Get pointer to true/false string based on input
'   Returns:
'       @"true" if val is non-zero
'       @"false" if val is zero
    if ( val )
        return @"true"
    else
        return @"false"

PUB setup{}

    ser.start(SER_BAUD)
    time.msleep(30)
    ser.clear{}
    ser.strln(@"Serial terminal started")

    if ( nfc.startx(I2C_SCL, I2C_SDA, I2C_FREQ) )
        ser.strln(@"ST25DVXX driver started")
    else
        ser.strln(@"ST25DVXX driver failed to start - halting")
        repeat

   
DAT
{
Copyright 2023 Jesse Burt

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute,
sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT
OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
}

