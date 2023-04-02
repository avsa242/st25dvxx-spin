{
    --------------------------------------------
    Filename: core.con.st25dvxx.spin
    Author: Jesse Burt
    Description: ST25DVxx-specific constants
    Copyright (c) 2023
    Started Mar 28, 2023
    Updated Apr 1, 2023
    See end of file for terms of use.
    --------------------------------------------
}

CON

' I2C Configuration
    I2C_MAX_FREQ            = 1_000_000         ' device max I2C bus freq
    SA_USR                  = $53 << 1
    SA_SYS                  = $57 << 1

    T_POR                   = 1_000                 ' startup time (usecs)
    T_WR                    = 5_000

    DEVID_RESP              = $00               ' device ID expected response

' NFC-common
    { capability container }
    CC_MAGIC_NUM            = 0
    CC_VER_ACCESS_COND      = 1
    CC_ADDTL_FEAT_INFO      = 3
    CC_MLEN                 = 6

' Register definitions
    { accessible via SA_SYS }
    GPO                     = $0000
        GPO_EN              = 1 << 7
        RF_WRITE_EN         = 1 << 6
        RF_GETMSG_EN        = 1 << 5
        RF_PUTMSG_EN        = 1 << 4
        FLD_CHNG_EN         = 1 << 3
        RF_INT_EN           = 1 << 2
        RF_ACTVTY_EN        = 1 << 1
        RF_USER_EN          = 1

    IT_TIME                 = $0001
    IT_TIME_MASK            = $07
        PLS_TIME            = %111

    EH_MODE                 = $0002             ' R/W (W only if I2C security session open)
    EH_MODE_MASK            = $01
        EHMODE              = 1
        EH_FORCE            = 0
        EH_ON_DEMAND        = 1

    RF_MNGT                 = $0003
    RF_MNGT_MASK            = $03
        RF_SLEEP            = 1 << 1
        RF_SLEEP_MASK       = RF_SLEEP ^ RF_MNGT_MASK
        RF_DISABLE          = 1
        RF_DISABLE_MASK     = RF_DISABLE ^ RF_MNGT_MASK

    { RFA1..4SS }
    RFAXSS_MASK             = $0f
        RF_RW_PROT          = 2
        RF_RW_PROT_BITS     = %11 << RF_RW_PROT
        RF_RW_PROT_MASK     = RF_RW_PROT_BITS ^ RFAXSS_MASK
        PWD_CTRL            = 0
        PWD_CTRL_BITS       = %11
        PWD_CTRL_MASK       = PWD_CTRL_BITS ^ RFAXSS_MASK
 
    RFA1SS                  = $0004
    RFA1SS_MASK             = $0f
        A1_RDALWAYS_WRNEVER = %11               ' R: always allowed, W: always forbidden
        A1_RDAL_WR_IF_USRSSO= %10               ' R: always allowed, W: allowed if sec. sess. open
'       A1_RDAL_WR_IF_USRSSO= %01               ' same as %10
        A1_RW_ALWAYS        = %00               ' R/W: always allowed
        A1_SSO_RF_PWD_3     = %11
        A1_SSO_RF_PWD_2     = %10
        A1_SSO_RF_PWD_1     = %01
        A1_SS_NOPWD         = %00

    ENDA1                   = $0005
    ENDA1_04K_DEF           = $0f
    ENDA1_16K_DEF           = $3f
    ENDA1_64K_DEF           = $ff

    RFA2SS                  = $0006
    RFA2SS_MASK             = $0f
        A2_RDALWAYS_WRNEVER = %11               ' R: always allowed, W: always forbidden
        A2_RW_IF_USRSSO     = %10               ' R/W: allowed if security session open
        A2_RDAL_WR_IF_USRSSO= %01               ' R: always allowed, W: allowed if sec. sess. open
        A2_RW_ALWAYS        = %00               ' R/W: always allowed
        A2_SSO_RF_PWD_3     = %11
        A2_SSO_RF_PWD_2     = %10
        A2_SSO_RF_PWD_1     = %01
        A2_SS_NOPWD         = %00

    ENDA2                   = $0007
    ENDA2_04K_DEF           = $0f
    ENDA2_16K_DEF           = $3f
    ENDA2_64K_DEF           = $ff

    RFA3SS                  = $0008
    RFA3SS_MASK             = $0f
        A3_RDALWAYS_WRNEVER = %11               ' R: always allowed, W: always forbidden
        A3_RW_IF_USRSSO     = %10               ' R/W: allowed if security session open
        A3_RDAL_WR_IF_USRSSO= %01               ' R: always allowed, W: allowed if sec. sess. open
        A3_RW_ALWAYS        = %00               ' R/W: always allowed
        A3_SSO_RF_PWD_3     = %11
        A3_SSO_RF_PWD_2     = %10
        A3_SSO_RF_PWD_1     = %01
        A3_SS_NOPWD         = %00

    ENDA3                   = $0009
    ENDA3_04K_DEF           = $0f
    ENDA3_16K_DEF           = $3f
    ENDA3_64K_DEF           = $ff

    RFA4SS                  = $000a
    RFA4SS_MASK             = $0f
        A4_RDALWAYS_WRNEVER = %11               ' R: always allowed, W: always forbidden
        A4_RW_IF_USRSSO     = %10               ' R/W: allowed if security session open
        A4_RDAL_WR_IF_USRSSO= %01               ' R: always allowed, W: allowed if sec. sess. open
        A4_RW_ALWAYS        = %00               ' R/W: always allowed
        A4_SSO_RF_PWD_3     = %11
        A4_SSO_RF_PWD_2     = %10
        A4_SSO_RF_PWD_1     = %01
        A4_SS_NOPWD         = %00

   I2CSS                   = $000b
    I2CSS_MASK              = $ff
        I2C_RW_PROT_A4      = %11 << 6
        A4_RW_IF_SSO        = %11
        A4_RD_IF_SSO_WR_ALW = %10
        A4_RD_ALW_WR_IF_SSO = %01
        A4_RW_ALWAYS        = %00
        I2C_RW_PROT_A3      = %11 << 4
        A3_RW_IF_SSO        = %11
        A3_RD_IF_SSO_WR_ALW = %10
        A3_RD_ALW_WR_IF_SSO = %01
        A3_RW_ALWAYS        = %00
        I2C_RW_PROT_A2      = %11 << 2
        A2_RW_IF_SSO        = %11
        A2_RD_IF_SSO_WR_ALW = %10
        A2_RD_ALW_WR_IF_SSO = %01
        A2_RW_ALWAYS        = %00
        I2C_RW_PROT_A1      = %11
        A1_RD_ALW_WR_IF_SSO = %11
'       A1_RW_ALWAYS        = %10
'       A1_RD_ALW_WR_IF_SSO = %01               ' same as %11
        A1_RW_ALWAYS        = %00               ' same as %10

    LOCK_CCFILE             = $000c
    LOCK_CCFILE_MASK        = $03
        { bits writable IF block(s) $00/$01 are not already locked }
        LCKBCK1             = 1 << 1
        LCKBCK1_MASK        = LCKBCK1 ^ LOCK_CCFILE_MASK
        LCKBCK0             = 1
        LCKBCK0_MASK        = LCKBCK0 ^ LOCK_CCFILE_MASK

    MB_MODE                 = $000d
    MB_WDG                  = $000e

    LOCK_CFG                = $000f
    LOCK_CFG_MASK           = $03
        LCK_CFG             = 1
        LOCKCFG             = 1
        UNLOCK_CFG          = 0
        CFG_LOCKED          = 1
        CFG_UNLOCKED        = 0

    LOCK_DSFID              = $0010
        DSFID_LOCKED        = 1
        DSFID_NOT_LOCKED    = 0

    LOCK_AFI                = $0011
        AFI_LOCKED          = 1
        AFI_NOT_LOCKED      = 0

    DSFID                   = $0012

    AFI                     = $0013

    MEM_SIZE                = $0014'..$0015
    BLK_SIZE                = $0016
    IC_REF                  = $0017
    UID                     = $0018'..$001f
    IC_REV                  = $0020

' RESERVED $0021..$0023 (R/O)

    I2C_PWD                 = $0900'..$0907
    I2C_PWD_CHANGE_CMD      = $07               ' change pwd command/token
    I2C_PWD_PRESENT_CMD     = $09               ' present pwd command/token
    I2C_PWD_PRESENT         = (I2C_PWD_PRESENT_CMD << 16) | I2C_PWD
    I2C_PWD_CHANGE          = (I2C_PWD_CHANGE_CMD << 16) | I2C_PWD

    GPO_CTRL                = $2000
    { see GPO in system regs above for field definitions }

    GPO_CTRL_MASK           = $ff

' RESERVED $2001

    EH_CTRL                 = $2002
    EH_CTRL_MASK            = $0f
'       RESERVED            = %1111 << 4
        VCC_ON              = 1 << 3            ' R/O
        FIELD_ON            = 1 << 2            '
        EH_ON               = 1
        EH_ON_BITS          = 1 << EH_ON        '
        EH_EN               = 0                 ' R/W
        EH_EN_MASK          = 1 ^ EH_CTRL_MASK

    RF_MNGT_DYN             = $2003
    RF_MNGT_DYN_MASK        = $03
    { see RF_MNGT in system regs above for field definitions }

    I2C_SSO                 = $2004
    I2C_SSO_MASK            = $01
        SESS_OPEN           = 1
        SESS_CLOSED         = 0

    IT_STS                  = $2005
        RF_WRITE            = 1 << 7
        RF_GET_MSG          = 1 << 6
        RF_PUT_MSG          = 1 << 5
        FLD_RISING          = 1 << 4
        FLD_FALLING         = 1 << 3
        RF_INTERRUPT        = 1 << 2
        RF_ACTIVITY         = 1 << 1
        RF_USER             = 1

    MB_CTRL                 = $2006
    MB_CTRL_MASK            = $01               ' W/O mask
        RF_CURR_MSG_ST      = 1 << 7
        HOST_CURR_MSG_ST    = 1 << 6
        RF_MISS_MSG_ST      = 1 << 5
        HOST_MISS_MSG_ST    = 1 << 4
        RF_PUT_MSG_ST       = 1 << 2
        RF_GET_MSG_ST       = 1 << 1
        MB_EN               = 1
        MB_EN_MASK          = MB_EN ^ MB_CTRL_MASK

    MB_LEN                  = $2007
        MB_LEN_BYTES        = 0                 ' -1

PUB null{}
' This is not a top-level object

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

