!==============================================================================!
  subroutine Numerics_Mod_Under_Relax(phi, A, b)
!------------------------------------------------------------------------------!
!   Purpose: Under-relax system of equations before calling linear solver.     !
!------------------------------------------------------------------------------!
  implicit none
!---------------------------------[Arguments]----------------------------------!
  type(Var_Type)    :: phi
  type(Matrix_Type) :: A
  real              :: b(:)
!-----------------------------------[Locals]-----------------------------------!
  integer :: c
!==============================================================================!

  !------------------------------------------!
  !   Browse through cells and under-relax   !
  !------------------------------------------!
  do c = 1, phi % pnt_grid % n_cells

    ! Under-relax central coefficient
    A % val(A % dia(c)) = A % val(A % dia(c)) / phi % urf

    ! Under-relax central coefficient
    b(c) = b(c) + A % val(A % dia(c)) * (1.0 - phi % urf) * phi % n(c)

  end do

  end subroutine
