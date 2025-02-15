-------------------------------------------------------------------------------
--  Copyright (c) 2019, CXOS.
--  This program is free software; you can redistribute it and/or modify it
--  under the terms of the GNU General Public License as published by the
--  Free Software Foundation; either version 3 of the License, or
--  (at your option) any later version.
--
--  Authors:
--     Anthony <ajxs [at] panoptic.online>
-------------------------------------------------------------------------------

with Ada.Unchecked_Conversion;

-------------------------------------------------------------------------------
--  X86.SERIAL
--
--  Purpose:
--    This package contains a basic Serial I/O driver.
--    The procedures and type definitions contained within this module can be
--    used to interact with the system's serial ports.
-------------------------------------------------------------------------------
package x86.Serial is
   pragma Preelaborate (x86.Serial);

   MAXIMUM_BAUD_RATE : constant := 115200;

   ----------------------------------------------------------------------------
   --  Serial Baud Rate
   ----------------------------------------------------------------------------
   subtype Baud_Rate is Natural range 50 .. MAXIMUM_BAUD_RATE;

   ----------------------------------------------------------------------------
   --  Serial Port Type
   --  Defines the serial ports that can be used in the system.
   ----------------------------------------------------------------------------
   type Serial_Port is (
     COM1,
     COM2,
     COM3,
     COM4
   );

   ----------------------------------------------------------------------------
   --  Serial Interrupt Type
   --  Defines the types of interrupts the serial port can generate.
   ----------------------------------------------------------------------------
   type Serial_Interrupt_Type is (
     Modem_Line_Status,
     Rx_Data_Available,
     Rx_Line_Status,
     Tx_Empty
   );

   ----------------------------------------------------------------------------
   --  Initialise
   --
   --  Purpose:
   --    This procedure initialises a particular serial port.
   --    This function will configure the baud rate, word length, parity
   --    and stop bits for a particular serial port.
   --  Exceptions:
   --    None.
   ----------------------------------------------------------------------------
   procedure Initialise (
     Port : Serial_Port;
     Rate : Baud_Rate := MAXIMUM_BAUD_RATE
   );

   ----------------------------------------------------------------------------
   --  Put_String
   --
   --  Purpose:
   --    This procedure prints a string to the selected serial port.
   --  Exceptions:
   --    None.
   ----------------------------------------------------------------------------
   procedure Put_String (
     Port : Serial_Port;
     Data : String
   );

private
   ----------------------------------------------------------------------------
   --  Get_Port_Address
   --
   --  Purpose:
   --    This function returns the port-mapped address of an individual serial
   --    port. It will return the address of COM1 in the event of any error.
   --  Exceptions:
   --    None.
   ----------------------------------------------------------------------------
   function Get_Port_Address (
     Port : Serial_Port
   ) return System.Address
   with Pure_Function;

   ----------------------------------------------------------------------------
   --  Is_Tx_Empty
   --
   --  Purpose:
   --    This function tests whether a particular port's transmission buffer is
   --    ready to accept new data.
   --    This is used during the various transmission functions to ensure that
   --    an overflow exception is not generated.
   --  Exceptions:
   --    None.
   ----------------------------------------------------------------------------
   function Is_Tx_Empty (
     Port : Serial_Port
   ) return Boolean
   with Volatile_Function;

   ----------------------------------------------------------------------------
   --  Put_Char
   --
   --  Purpose:
   --    This procedure prints a character to a serial port.
   --  Exceptions:
   --    None.
   ----------------------------------------------------------------------------
   procedure Put_Char (
     Port : Serial_Port;
     Data : Unsigned_8
   );

   ----------------------------------------------------------------------------
   --  Set_Baud_Rate
   --
   --  Purpose:
   --    This procedure sets the baud rate for a particular serial port.
   --  Exceptions:
   --    None.
   ----------------------------------------------------------------------------
   procedure Set_Baud_Rate (
     Port : Serial_Port;
     Rate : Baud_Rate
   );

   ----------------------------------------------------------------------------
   --  Set_Interrupt_Generation
   --
   --  Purpose:
   --    This procedure enables or disables the generation of interrupts
   --    of a particular type.
   --  Exceptions:
   --    None.
   ----------------------------------------------------------------------------
   procedure Set_Interrupt_Generation (
     Port           : Serial_Port;
     Interrupt_Type : Serial_Interrupt_Type;
     Status         : Boolean
   );

   ----------------------------------------------------------------------------
   --  Set_Divisor_Latch_State
   --
   --  Purpose:
   --    This procedure sets the divisor latch state for a particular serial
   --    peripheral.
   --    This will set the DLAB state for the selected serial peripheral.
   --    For more information regarding the use of this procedure refer to the
   --    16550 UART documentation.
   --  Exceptions:
   --    None.
   ----------------------------------------------------------------------------
   procedure Set_Divisor_Latch_State (
     Port  : Serial_Port;
     State : Boolean
   );

   ----------------------------------------------------------------------------
   --  Port Interrupt status/enable register type.
   --  This type can be used for getting/setting the interrupt generation
   --  status of a particular interrupt type.
   --  For more information refer to page 17 of the PC16550D datasheet.
   ----------------------------------------------------------------------------
   type Port_Interrupt_Status is
      record
         ERBFI : Boolean;
         ETBEI : Boolean;
         ELSI  : Boolean;
         EDSSI : Boolean;
      end record
   with Size => 8,
     Convention => C,
     Volatile;
   for Port_Interrupt_Status use
      record
         ERBFI at 0 range 0 .. 0;
         ETBEI at 0 range 1 .. 1;
         ELSI  at 0 range 2 .. 2;
         EDSSI at 0 range 3 .. 3;
      end record;

   ----------------------------------------------------------------------------
   --  Byte_To_Port_Interrupt_Status
   --
   --  Purpose:
   --    Unchecked conversion to read a port's interrupt status from
   --    an IO port.
   --  Exceptions:
   --    None.
   ----------------------------------------------------------------------------
   function Byte_To_Port_Interrupt_Status is
      new Ada.Unchecked_Conversion (
        Source => Unsigned_8,
        Target => Port_Interrupt_Status
      );

   ----------------------------------------------------------------------------
   --  Port_Interrupt_Status_To_Byte
   --
   --  Purpose:
   --    Unchecked conversion to write a port's interrupt status to
   --    an IO port.
   --  Exceptions:
   --    None.
   ----------------------------------------------------------------------------
   function Port_Interrupt_Status_To_Byte is
      new Ada.Unchecked_Conversion (
        Source => Port_Interrupt_Status,
        Target => Unsigned_8
      );

end x86.Serial;
