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

-------------------------------------------------------------------------------
--  SYSTEM.X86.MEMORY.MAP
--
--  Purpose:
--    This package contains code and defintions for working with a map of
--    usable memory on the system.
-------------------------------------------------------------------------------
package x86.Memory.Map is
   pragma Preelaborate (x86.Memory.Map);

   ----------------------------------------------------------------------------
   --  Memory Map Process Result
   --  Used for storing and returning the result of an internal memory map
   --  procedure.
   ----------------------------------------------------------------------------
   type Process_Result is (
     Invalid_Address_Argument,
     Invalid_Index_Argument,
     No_Free_Frames,
     Success
   );

   ----------------------------------------------------------------------------
   --  Memory Map Frame type.
   --  Represents the presence of an individual page frame in memory.
   ----------------------------------------------------------------------------
   type Memory_Map_Frame_State is (
     Allocated,
     Unallocated
   )
   with Size => 1;
   for Memory_Map_Frame_State use (
     Allocated   => 0,
     Unallocated => 1
   );

   ----------------------------------------------------------------------------
   --  Initialise
   --
   --  Purpose:
   --    This procedure initialises the system memory map.
   --    Every page frame is initialised as being allocated and non-free.
   --  Exceptions:
   --    None.
   ----------------------------------------------------------------------------
   procedure Initialise;

   ----------------------------------------------------------------------------
   --  Allocate_Frame
   --
   --  Purpose:
   --    Finds and allocates a free page frame for a process.
   --  Exceptions:
   --    None.
   ----------------------------------------------------------------------------
   function Allocate_Frame (
     Addr : out System.Address
   ) return Process_Result
   with Volatile_Function;

   ----------------------------------------------------------------------------
   --  Mark_Memory_Range
   --
   --  Purpose:
   --    This function marks a memory range as being either allocated or free.
   --  Exceptions:
   --    None.
   ----------------------------------------------------------------------------
   function Mark_Memory_Range (
     Base   : System.Address;
     Length : Unsigned_32;
     Status : Memory_Map_Frame_State
   ) return Process_Result;

private
   ----------------------------------------------------------------------------
   --  Find_Free_Frame
   --
   --  Purpose:
   --    This function returns the index of the first free frame.
   --  Exceptions:
   --    None.
   ----------------------------------------------------------------------------
   function Find_Free_Frame (
     Index : out Natural
   ) return Process_Result;

   ----------------------------------------------------------------------------
   --  Set_Frame_State
   --
   --  Purpose:
   --    This procedure sets the status of a memory frame at a particular
   --    address.
   --  Exceptions:
   --    None.
   ----------------------------------------------------------------------------
   function Set_Frame_State (
     Addr  : System.Address;
     State : Memory_Map_Frame_State
   ) return Process_Result;

   ----------------------------------------------------------------------------
   --  Set_Frame_State
   --
   --  Purpose:
   --    This procedure sets the status of a memory frame at a particular
   --    index in the frame array.
   --  Exceptions:
   --    None.
   ----------------------------------------------------------------------------
   function Set_Frame_State (
     Index : Natural;
     State : Memory_Map_Frame_State
   ) return Process_Result;

   ----------------------------------------------------------------------------
   --  Get_Frame_Address
   --
   --  Purpose:
   --    This function gets the physical memory address corresponding to an
   --    individual memory map frame.
   --  Exceptions:
   --    None.
   ----------------------------------------------------------------------------
   function Get_Frame_Address (
     Index : Natural;
     Addr  : out System.Address
   ) return Process_Result
   with Pure_Function;

   ----------------------------------------------------------------------------
   --  Get_Frame_Index
   --
   --  Purpose:
   --    This function gets the index into the memory map of the frame
   --    corresponding to a particular address.
   --  Exceptions:
   --    None.
   ----------------------------------------------------------------------------
   function Get_Frame_Index (
     Addr  : System.Address;
     Index : out Natural
   ) return Process_Result
   with Pure_Function;

   ----------------------------------------------------------------------------
   --  Memory Map Array type.
   --  Represents all page frames across the full linear address space.
   ----------------------------------------------------------------------------
   type Memory_Map_Array is array (Natural range 0 .. 16#100000#)
     of Memory_Map_Frame_State
   with Pack;

   ----------------------------------------------------------------------------
   --  The system memory map.
   ----------------------------------------------------------------------------
   Memory_Map : Memory_Map_Array;

end x86.Memory.Map;
