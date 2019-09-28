with Interfaces;
with System.Storage_Elements;
with x86.Port_IO;

package body x86.PIC is
   use Interfaces;
   use System.Storage_Elements;

   ----------------------------------------------------------------------------
   --  Get_Port_Address
   --
   --  Implementation Notes:
   --   - Returns a constant value stored within the function.
   ----------------------------------------------------------------------------
   function Get_Controller_Base_Address (
      Controller : PIC_Controller
   ) return System.Address is
      PIC1_Base_Addr : constant System.Address := To_Address (16#20#);
      PIC2_Base_Addr : constant System.Address := To_Address (16#A0#);
   begin
      case Controller is
         when PIC1 =>
            return PIC1_Base_Addr;
         when PIC2 =>
            return PIC2_Base_Addr;
      end case;
   exception
      when Constraint_Error =>
         return PIC1_Base_Addr;
   end Get_Controller_Base_Address;

   ----------------------------------------------------------------------------
   --  Initialise
   --
   --  Implementation Notes:
   --   - Does not preserve configured interrupt mask during initialisation.
   ----------------------------------------------------------------------------
   procedure Initialise is
      PIC1_Addr : constant System.Address :=
        Get_Controller_Base_Address (PIC1);
      PIC2_Addr : constant System.Address :=
        Get_Controller_Base_Address (PIC2);
   begin
      --  Begin initialization mode.
      x86.Port_IO.Outb (PIC1_Addr, 16#11#);
      x86.Port_IO.Outb (PIC2_Addr, 16#11#);

      x86.Port_IO.Outb (PIC1_Addr + 1, 16#20#);
      x86.Port_IO.Outb (PIC2_Addr + 1, 16#28#);

      --  Tell the master PIC that there is a slave PIC at IRQ2
      x86.Port_IO.Outb (PIC1_Addr + 1, 16#04#);
      --  Tell the slave PIC its cascade identity
      x86.Port_IO.Outb (PIC2_Addr + 1, 16#02#);

      x86.Port_IO.Outb (PIC1_Addr + 1, 16#01#);
      x86.Port_IO.Outb (PIC2_Addr + 1, 16#01#);

   end Initialise;

   ----------------------------------------------------------------------------
   --  Send_EOI
   ----------------------------------------------------------------------------
   procedure Send_EOI (
     IRQ : Interrupt_Source
   ) is
      EOI_Signal      : constant Unsigned_8 := 16#20#;
      Controller_Addr : System.Address;
   begin
      --  Get the correct controller address to send the EOI signal to.
      Get_Controller_Address :
         begin
            if IRQ >= 8 then
               Controller_Addr := Get_Controller_Base_Address (PIC2);
            else
               Controller_Addr := Get_Controller_Base_Address (PIC1);
            end if;
         end Get_Controller_Address;

      --  Send the signal.
      x86.Port_IO.Outb  (Controller_Addr, EOI_Signal);
   end Send_EOI;
end x86.PIC;
