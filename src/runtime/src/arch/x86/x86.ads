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

with Interfaces;
with Multiboot;
with System;

-------------------------------------------------------------------------------
--  SYSTEM.X86
--
--  Purpose:
--    This package contains initialisation code for the x86 system.
--    The initialisation procedure here will perform all the required
--    initialisation code for the platform.
-------------------------------------------------------------------------------
package x86 is
   pragma Preelaborate (x86);

   use Interfaces;
   use Multiboot;

   type Kernel_Process_Result is (
     Failure,
     Success
   );

   ----------------------------------------------------------------------------
   --  Initialise
   --
   --  Purpose:
   --    This procedure initialises the x86 platform.
   --    This will perform all the necessary initialisation in order to load
   --    and begin execution of the kernel.
   --  Exceptions:
   --    None.
   ----------------------------------------------------------------------------
   procedure Initialise (
     Magic_Number      : Multiboot_Magic_Number;
     Boot_Info_Address : System.Address
   )
   with Export,
     Convention => Assembler,
     External_Name => "__system_init";

private
   ----------------------------------------------------------------------------
   --  Install_Exception_Handlers
   --
   --  Purpose:
   --    This procedure installs the processor exception handlers.
   --  Exceptions:
   --    None.
   ----------------------------------------------------------------------------
   procedure Install_Exception_Handlers;

   ----------------------------------------------------------------------------
   --  Last_Chance_Handler
   --
   --  Purpose:
   --    The runtime Last_Chance_Handler function.
   --    This procedure is the GNAT mandated handler for any uncaught
   --    exceptions that are propagated to the top level.
   --    This runtime, like other bareboard targets, does not support exception
   --    propagation. So any uncaught exception will be handled here.
   --  Exceptions:
   --    None.
   ----------------------------------------------------------------------------
   procedure Last_Chance_Handler (
     Msg  : System.Address;
     Line : Integer
   ) with Export,
     Convention => C,
     External_Name => "__gnat_last_chance_handler";

   ----------------------------------------------------------------------------
   --  Mark_Low_Memory
   --
   --  Purpose:
   --    This procedure marks all memory below 1M as being non-free in the
   --    kernel memory map.
   --  Exceptions:
   --    None.
   ----------------------------------------------------------------------------
   function Mark_Low_Memory return Kernel_Process_Result;

   ----------------------------------------------------------------------------
   --  Mark_Kernel_Memory
   --
   --  Purpose:
   --    This procedure marks the memory used by the kernel as being allocated
   --    and non-free in the memory map.
   --  Exceptions:
   --    None.
   ----------------------------------------------------------------------------
   function Mark_Kernel_Memory return Kernel_Process_Result;

   ----------------------------------------------------------------------------
   --  Map_Vga_Memory
   --
   --  Purpose:
   --    Maps VGA memory to a usable virtual memory address.
   --  Exceptions:
   --    None.
   ----------------------------------------------------------------------------
   function Map_Vga_Memory return Kernel_Process_Result;

   ----------------------------------------------------------------------------
   --  Clear_Boot_Page_Structures
   --
   --  Purpose:
   --    This procedure marks the boot page structures as being unallocated
   --    memory, free for being overwritten.
   --  Exceptions:
   --    None.
   ----------------------------------------------------------------------------
   procedure Clear_Boot_Page_Structures;

   ----------------------------------------------------------------------------
   --  Parse_Multiboot_Memory_Map
   --
   --  Purpose:
   --    Parses the multiboot memory map structures, mapping the specified
   --    memory regions listed in the multiboot structure.
   --  Exceptions:
   --    None.
   ----------------------------------------------------------------------------
   procedure Parse_Multiboot_Memory_Map (
      Memory_Map_Addr   : System.Address;
      Memory_Map_Length : Unsigned_32
   );

   ----------------------------------------------------------------------------
   --  Protected_Mode_Init
   --
   --  Purpose:
   --    Performs the final jump to protected mode.
   --  Exceptions:
   --    None.
   ----------------------------------------------------------------------------
   procedure Protected_Mode_Init
   with Import,
     Convention    => Assembler,
     External_Name => "__protected_mode_init";
end x86;
