!==============================================================================!
  subroutine Control_Mod_Hybrid_Les_Rans_Switch(val, verbose)
!------------------------------------------------------------------------------!
!   Reading switch for hybrid LES/RANS model.                                  !
!------------------------------------------------------------------------------!
  implicit none
!---------------------------------[Arguments]----------------------------------!
  character(SL), intent(out) :: val
  logical,       optional    :: verbose
!==============================================================================!

  call Control_Mod_Read_Char_Item('HYBRID_LES_RANS_SWITCH',   &
                                  'SWITCH_DISTANCE',          &
                                   val, verbose)
  call String % To_Upper_Case(val)

  end subroutine
