!==============================================================================!
  logical function Backup_Mod_Time_To_Save(curr_dt)
!------------------------------------------------------------------------------!
  implicit none
!---------------------------------[Arguments]----------------------------------!
  integer :: curr_dt  ! current time step
!==============================================================================!

  Backup_Mod_Time_To_Save = mod(curr_dt, backup % interval) .eq. 0  &
                            .and. .not. curr_dt .eq. 0

  end function
