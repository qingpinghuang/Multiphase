!==============================================================================!
  subroutine Dashed_Line(Msg, w)
!----------------------------------[Modules]-----------------------------------!
  use Const_Mod
!------------------------------------------------------------------------------!
  implicit none
!---------------------------------[Arguments]----------------------------------!
  class(Message_Type) :: Msg
  integer, intent(in) :: w  ! width
!-----------------------------------[Locals]-----------------------------------!
  integer       :: i
  character(DL) :: line
!==============================================================================!

  ! _assert_(w <= DL)

  line = ' '
  do i = 3, w+1, 2
    write(line(i:i), '(a1)')  '-'
  end do

  write(line(2:2), '(a1)')  '#'

  print '(a)', line(1:w+1)

  end subroutine

