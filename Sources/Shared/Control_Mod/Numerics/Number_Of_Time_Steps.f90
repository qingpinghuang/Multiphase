!==============================================================================!
  subroutine Control_Mod_Number_Of_Time_Steps(val, verbose)
!------------------------------------------------------------------------------!
  implicit none
!---------------------------------[Arguments]----------------------------------!
  integer, intent(out) :: val
  logical, optional    :: verbose
!==============================================================================!

  call Control_Mod_Read_Int_Item('NUMBER_OF_TIME_STEPS', 1200, &
                                  val, verbose)

  end subroutine
