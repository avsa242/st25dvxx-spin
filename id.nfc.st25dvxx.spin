{
    --------------------------------------------
    Filename: id.nfc.st25dvxx.spin
    Author: Jesse Burt
    Description: Driver for the ST25DVxx-series NFC/RFID tag w/EEPROM
    Copyright (c) 2023
    Started Mar 28, 2023
    Updated Apr 1, 2023
    See end of file for terms of use.
    --------------------------------------------
}
#include "memory.common.spinh"

CON

    SA_SYS_WR           = core#SA_SYS
    SA_SYS_RD           = SA_SYS_WR | 1
    SA_USR_WR           = core#SA_USR
    SA_USR_RD           = SA_USR_WR | 1

    DEF_SCL             = 28
    DEF_SDA             = 29
    DEF_HZ              = 100_000
    I2C_MAX_FREQ        = core#I2C_MAX_FREQ

    ERASE_CELL          = $00
    ST25_EE_MAX_SZ      = 8192

OBJ

{ decide: Bytecode I2C engine, or PASM? Default is PASM if BC isn't specified }
#ifdef ST25DVXX_I2C_BC
    i2c : "com.i2c.nocog"                       ' BC I2C engine
#else
    i2c : "com.i2c"                             ' PASM I2C engine
#endif
    core: "core.con.st25dvxx.spin"              ' hw-specific constants
    time: "time"                                ' basic timing functions

PUB null{}
' This is not a top-level object

PUB start{}: status
' Start using "standard" Propeller I2C pins and 100kHz
    return startx(DEF_SCL, DEF_SDA, DEF_HZ)

PUB startx(SCL_PIN, SDA_PIN, I2C_HZ): status
' Start using custom IO pins and I2C bus frequency
    if (lookdown(SCL_PIN: 0..31) and lookdown(SDA_PIN: 0..31))
        if (status := i2c.init(SCL_PIN, SDA_PIN, I2C_HZ))
            time.usleep(core#T_POR)             ' wait for device startup
            if (i2c.present(SA_SYS_WR))         ' test device bus presence
                return
    ' if this point is reached, something above failed
    ' Re-check I/O pin assignments, bus speed, connections, power
    ' Lastly - make sure you have at least one free core/cog 
    return FALSE

PUB stop{}
' Stop the driver
    i2c.deinit{}

PUB defaults{}
' Set factory defaults

PUB app_fam_id_locked{}: l
' Application family ID locked
'   Returns:
'       TRUE (-1): AFI is locked
'       FALSE (0): AFI is not locked
    l := 0
    readreg(core#LOCK_AFI, 1, @l)
    return ((l & 1) == core#AFI_LOCKED)

PUB app_fam_id{}: i
' Application family identifier
    i := 0
    readreg(core#AFI, 1, @i)

PUB blk0_write_protected{}: p
' Block 0 write protection status
'   Returns:
'       TRUE (-1): block 0 is write-protected/locked
'       FALSE (0): block 0 is not write-protected/locked
    p := 0
    readreg(core#LOCK_CCFILE, 1, @p)
    return ( (p & core#LCKBCK0) == core#LCKBCK0 )

PUB blk1_write_protected{}: p
' Block 1 write protection status
'   Returns:
'       TRUE (-1): block 1 is write-protected/locked
'       FALSE (0): block 1 is not write-protected/locked
    p := 0
    readreg(core#LOCK_CCFILE, 1, @p)
    return ( (p & core#LCKBCK1) == core#LCKBCK1 )

PUB capacity{}: c | msz, bsz
' Total memory capacity, in bytes
    msz := bsz := 0
    readreg(core#MEM_SIZE, 2, @msz)
    readreg(core#BLK_SIZE, 1, @bsz)
    return ( (msz + 1) * (bsz + 1) ) * 8

PUB config_locked{}: l
' Configuration locked
    l := 0
    readreg(core#LOCK_CFG, 1, @l)
    return ( (l & 1) == core#CFG_LOCKED )

PUB data_storage_fmt_id{}: i
' Data storage format identifier
    i := 0
    readreg(core#DSFID, 1, @i)

PUB data_storage_fmt_id_locked{}: l
' Data storage format ID locked
'   Returns:
'       TRUE (-1): DSF ID is locked
'       FALSE (0): DSF ID is not locked
    l := 0
    readreg(core#LOCK_DSFID, 1, @l)
    return ( (l & 1) == core#DSFID_LOCKED )

PUB energy_harvest_ena(state): curr_state
' Enable energy-harvesting feature
'   Valid values:
'       TRUE (-1 or 1), FALSE (0)
'   Any other value returns the current setting
    curr_state := 0
    readreg(core#EH_CTRL, 1, @curr_state)
    case ||(state)
        0, 1:
            state &= 1
            writereg(core#EH_CTRL, 1, @state)
        other:
            return ((curr_state & core#EH_ON_BITS) <> 0)

PUB i2c_change_passwd(ptr_pw): status
' Change the I2C security session password
'   ptr_pw: pointer to 64-bit/8-byte password (default: 00_00_00_00_00_00_00_00)
'   Returns:
'       0: success
'       -1: error (security session not open, fast transfer mode active, or communication error)
'   NOTE: The I2C security session must be opened first for this function call to be successful
'       (i.e., call i2c_present_passwd() with the correct current session password)
    return writereg(core#I2C_PWD_CHANGE, 8, ptr_pw)

PUB i2c_present_passwd(ptr_pw): status
' Present the I2C security session password to the device
'   ptr_pw: pointer to 64-bit/8-byte password (default: 00_00_00_00_00_00_00_00)
    return writereg(core#I2C_PWD_PRESENT, 8, ptr_pw)

PUB i2c_security_sess_open{}: o
' I2C security session open status
'   Returns:
'       TRUE (-1): I2C security session is open
'       FALSE (0): I2C security session is not open
    o := 0
    readreg(core#I2C_SSO, 1, @o)
    return ( (o & 1) == core#SESS_OPEN )

PUB rd_block_lsbf(ptr_buff, addr, nr_bytes) | cmd_pkt
' Read a block of memory, least-significant byte (byte[ptr_buff][0]) first
'   ptr_buff: pointer to buffer to read data into
'   addr: starting EEPROM address
'   nr_bytes: number of bytes to read
    cmd_pkt.byte[0] := (core#SA_USR)
    cmd_pkt.byte[1] := addr.byte[1]
    cmd_pkt.byte[2] := addr.byte[0]
    i2c.start{}
    i2c.wrblock_lsbf(@cmd_pkt, 3)

    i2c.start{}
    i2c.write(core#SA_USR | 1)
    i2c.rdblock_lsbf(ptr_buff, nr_bytes, i2c#NAK)
    i2c.stop{}

PUB rd_block_msbf(ptr_buff, addr, nr_bytes) | cmd_pkt
' Read a block of memory, most-significant byte (byte[ptr_buff][nr_bytes-1]) first
'   ptr_buff: pointer to buffer to read data into
'   addr: starting EEPROM address
'   nr_bytes: number of bytes to read
    cmd_pkt.byte[0] := (core#SA_USR)
    cmd_pkt.byte[1] := addr.byte[1]
    cmd_pkt.byte[2] := addr.byte[0]
    i2c.start{}
    i2c.wrblock_lsbf(@cmd_pkt, 3)

    i2c.start{}
    i2c.write(core#SA_USR | 1)
    i2c.rdblock_msbf(ptr_buff, nr_bytes, i2c#NAK)
    i2c.stop{}

PUB revision{}: r
' IC revision
    r := 0
    readreg(core#IC_REV, 1, @r)

PUB rf_area_rw_policy(n): p
' RF area read/write policy/access
'   n: RF area (1..4)
'   Returns:
'       when n == 1:
'           %00: read/write always allowed
'           %01: read always allowed, write allowed if security session open
'           %10: same as %01
'           %11: read always allowed, write never allowed
'       when n == 3..4:
'           %00: read/write always allowed
'           %01: read always allowed, write allowed if security session open
'           %10: read/write allowed if security session open
'           %11: read always allowed, write never allowed
    n := (1 #> n <# 4)
    p := 0
    readreg(core#RFA1SS + ((n-1) * 2), 1, @p)
    return ( p >> core#RF_RW_PROT ) & core#RF_RW_PROT_BITS

PUB rf_area_pwd_policy(n): p
' RF area user security session open by password
'   n: RF area (1..4)
'   Returns:
'       %00: RF area n user security session can't be opened by password
'       %01: RF area n user security session opened by RF password 1
'       %10: RF area n user security session opened by RF password 2
'       %11: RF area n user security session opened by RF password 3
    n := (1 #> n <# 4)
    p := 0
    readreg(core#RFA1SS + ((n-1) * 2), 1, @p)
    return ( p & core#PWD_CTRL_BITS )

PUB rf_area1_pwd_policy{}: p
' RF area 1 user security session open by password
'   Returns:
'       %00: RF area 1 user security session can't be opened by password
'       %01: RF area 1 user security session opened by RF password 1
'       %10: RF area 1 user security session opened by RF password 2
'       %11: RF area 1 user security session opened by RF password 3
    return rf_area_pwd_policy(1)

PUB rf_area1_rw_policy{}: p
' RF area 1 read/write policy/access
'   Returns:
'       %00: read/write always allowed
'       %01: read always allowed, write allowed if security session open
'       %10: same as %01
'       %11: read always allowed, write never allowed
    return rf_area_rw_policy(1)

PUB rf_area2_pwd_policy{}: p
' RF area 2 user security session open by password
'   Returns:
'       %00: RF area 2 user security session can't be opened by password
'       %01: RF area 2 user security session opened by RF password 1
'       %10: RF area 2 user security session opened by RF password 2
'       %11: RF area 2 user security session opened by RF password 3
    return rf_area_pwd_policy(2)

PUB rf_area2_rw_policy{}: p
' RF area 2 read/write policy/access
'   Returns:
'       %00: read/write always allowed
'       %01: read always allowed, write allowed if security session open
'       %10: read/write allowed if security session open
'       %11: read always allowed, write never allowed
    return rf_area_rw_policy(2)

PUB rf_area3_pwd_policy{}: p
' RF area 3 user security session open by password
'   Returns:
'       %00: RF area 3 user security session can't be opened by password
'       %01: RF area 3 user security session opened by RF password 1
'       %10: RF area 3 user security session opened by RF password 2
'       %11: RF area 3 user security session opened by RF password 3
    return rf_area_pwd_policy(3)

PUB rf_area3_rw_policy{}: p
' RF area 3 read/write policy/access
'   Returns:
'       %00: read/write always allowed
'       %01: read always allowed, write allowed if security session open
'       %10: read/write allowed if security session open
'       %11: read always allowed, write never allowed
    return rf_area_rw_policy(3)

PUB rf_area4_pwd_policy{}: p
' RF area 4 user security session open by password
'   Returns:
'       %00: RF area 4 user security session can't be opened by password
'       %01: RF area 4 user security session opened by RF password 1
'       %10: RF area 4 user security session opened by RF password 2
'       %11: RF area 4 user security session opened by RF password 3
    return rf_area_pwd_policy(4)

PUB rf_area4_rw_policy{}: p
' RF area 4 read/write policy/access
'   Returns:
'       %00: read/write always allowed
'       %01: read always allowed, write allowed if security session open
'       %10: read/write allowed if security session open
'       %11: read always allowed, write never allowed
    return rf_area_rw_policy(4)

PUB rf_field_detected{}: d
' Flag indicating RF field is detected
'       TRUE (-1): RF field is detected
'       FALSE (0): RF field is not detected
    d := 0
    readreg(core#EH_CTRL, 1, @d)
    return( (d & core#FIELD_ON) <> 0 )

PUB serial_num(ptr_buff)
' Read device serial number
'   ptr_buff: pointer to byte array of at least 8 bytes in length
'       byte[ptr_buff][0..4]: UID byte 0 (LSB)..byte 4
'       byte[ptr_buff][5]: ST product code
'           ST25DV04K-IE: $24
'           ST25DV16K-IE: $26
'           ST25DV64K-IE: $26
'           ST25DV04K-JF: $25
'           ST25DV16K-JF: $27
'           ST25DV64K-JF: $27
'       byte[ptr_buff][6]: IC manufacturing code ($02)
'       byte[ptr_buff][7]: UID byte 7 (MSB)
    readreg(core#UID, 8, ptr_buff)

PUB vcc_detected{}: d
' Flag indicating DC supply voltage detected
'   Returns:
'       TRUE (-1): Vcc supply is present and low power down mode is not forced
'       FALSE (0): Vcc supply is not present or low power down mode is forced
    d := 0
    readreg(core#EH_CTRL, 1, @d)
    return ( (d & core#VCC_ON) <> 0 )

PUB wr_block_lsbf(addr, ptr_buff, nr_bytes) | cmd_pkt, nr_pg
' Write a block of memory, least-significant byte (byte[ptr_buff][0]) first
'   ptr_buff: pointer to buffer containing data to write to EEPROM
'   addr: starting EEPROM address
'   nr_bytes: number of bytes to write
    cmd_pkt.byte[0] := core#SA_USR
    cmd_pkt.byte[1] := addr.byte[1]
    cmd_pkt.byte[2] := addr.byte[0]
    i2c.start{}
    i2c.wrblock_lsbf(@cmd_pkt, 3)
    i2c.wrblock_lsbf(ptr_buff, nr_bytes)
    i2c.stop{}
    nr_pg := 1 #> (nr_bytes >> 2) { /4 }
    time.usleep(nr_pg * core#T_WR)

PUB wr_block_msbf(addr, ptr_buff, nr_bytes) | cmd_pkt, nr_pg
' Write a block of memory, most-significant byte (byte[ptr_buff][nr_bytes-1]) first
'   ptr_buff: pointer to buffer containing data to write to EEPROM
'   addr: starting EEPROM address
'   nr_bytes: number of bytes to write
    cmd_pkt.byte[0] := core#SA_USR
    cmd_pkt.byte[1] := addr.byte[1]
    cmd_pkt.byte[2] := addr.byte[0]
    i2c.start{}
    i2c.wrblock_lsbf(@cmd_pkt, 3)
    i2c.wrblock_msbf(ptr_buff, nr_bytes)
    i2c.stop{}
    nr_pg := 1 #> (nr_bytes >> 2) { /4 }
    time.usleep(nr_pg * core#T_WR)

PRI readreg(reg_nr, nr_bytes, ptr_buff): status | cmd_pkt
' Read register(s) from device
'   Returns:
'       0: success
'       -1: error
    status := 0
    case reg_nr                                 ' validate register num
        $0000..$0020, $0900..$0907:
            { system regs }
            cmd_pkt.byte[0] := SA_SYS_WR
            cmd_pkt.byte[1] := reg_nr.byte[1]
            cmd_pkt.byte[2] := reg_nr.byte[0]
            i2c.start{}
            i2c.wrblock_lsbf(@cmd_pkt, 3)
            i2c.start{}
            i2c.wr_byte(SA_SYS_RD)
            i2c.rdblock_lsbf(ptr_buff, nr_bytes, i2c#NAK)
            i2c.stop{}
        $2000..$2007:
            { dynamic regs }
            cmd_pkt.byte[0] := SA_USR_WR
            cmd_pkt.byte[1] := reg_nr.byte[1]
            cmd_pkt.byte[2] := reg_nr.byte[0]
            i2c.start{}
            i2c.wrblock_lsbf(@cmd_pkt, 3)
            i2c.start{}
            i2c.wr_byte(SA_USR_RD)
            i2c.rdblock_lsbf(ptr_buff, nr_bytes, i2c#NAK)
            i2c.stop{}
        other:                                  ' invalid reg_nr

PRI writereg(reg_nr, nr_bytes, ptr_buff): status | cmd_pkt
' Write data to device register(s)
'   Returns:
'       0: device acknowledged
'       -1: device didn't acknowledge/error
    case reg_nr                                 ' validate register num
        core#I2C_PWD_CHANGE, core#I2C_PWD_PRESENT:
            { system regs }
            cmd_pkt.byte[0] := SA_SYS_WR
            cmd_pkt.byte[1] := reg_nr.byte[1]
            cmd_pkt.byte[2] := reg_nr.byte[0]
            i2c.start{}
            i2c.wrblock_lsbf(@cmd_pkt, 3)
            { to properly present the password to the device, it must be sent twice with a special
                "validation" token in-between }
            status := i2c.wrblock_lsbf(ptr_buff, nr_bytes)
            status |= i2c.wr_byte(reg_nr.byte[2])
            status |= i2c.wrblock_lsbf(ptr_buff, nr_bytes)
            i2c.stop{}

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

