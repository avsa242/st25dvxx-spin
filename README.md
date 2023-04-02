# st25dvxx-spin
---------------

This is a P8X32A/Propeller, P2X8C4M64P/Propeller 2 driver object for the ST25DVxx-series dynamic
NFC/RFID tag ICs with integrated EEPROM.

**IMPORTANT**: This software is meant to be used with the [spin-standard-library](https://github.com/avsa242/spin-standard-library) (P8X32A) or [p2-spin-standard-library](https://github.com/avsa242/p2-spin-standard-library) (P2X8C4M64P). Please install the applicable library first before attempting to use this code, otherwise you will be missing several files required to build the project.

## Salient Features

* I2C connection at ~25kHz (P1: bytecode-based I2C engine), 1MHz (P1: PASM-based I2C engine, P2)
* Read/write to the embedded EEPROM over I2C (uses [memory.md API](https://github.com/avsa242/spin-standard-library/blob/testing/api/memory.md)
* Present, change security session password (I2C)
* Read serial number
* Read RF individual area R/W and password policies
* Read lock flags
* Enable/disable energy-harvesting feature

## Requirements

P1/SPIN1:
* spin-standard-library

P2/SPIN2:
* ~~p2-spin-standard-library~~ _(not yet implemented)_

## Compiler Compatibility

| Processor | Language | Compiler               | Backend     | Status                |
|-----------|----------|------------------------|-------------|-----------------------|
| P1	    | SPIN1    | FlexSpin (5.9.25-beta)	| Bytecode    | OK                    |
| P1	    | SPIN1    | FlexSpin (5.9.25-beta) | Native code | OK                    |
| P1        | SPIN1    | OpenSpin (1.00.81)     | Bytecode    | Untested (deprecated) |
| P2	    | SPIN2    | FlexSpin (5.9.25-beta) | NuCode      | Not yet implemented   |
| P2        | SPIN2    | FlexSpin (5.9.25-beta) | Native code | Not yet implemented   |
| P1        | SPIN1    | Brad's Spin Tool (any) | Bytecode    | Unsupported           |
| P1, P2    | SPIN1, 2 | Propeller Tool (any)   | Bytecode    | Unsupported           |
| P1, P2    | SPIN1, 2 | PNut (any)             | Bytecode    | Unsupported           |

## Limitations

* Very early in development - may malfunction, or outright fail to build
* Most I2C-changeable settings not implemented yet (read-only)
* No handling of capabilities container (CC) file
* TBD
* TBD
* TBD
* TBD
* TBD
* TBD
* TBD
* TBD

