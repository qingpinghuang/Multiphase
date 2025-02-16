!==============================================================================!
  subroutine Face_Mod_Allocate(phi, Grid, name_phi)
!------------------------------------------------------------------------------!
!   This is to allocate a face-based uknown with new and old values.           !
!------------------------------------------------------------------------------!
  implicit none
!---------------------------------[Arguments]----------------------------------!
  type(Face_Type)         :: phi
  type(Grid_Type), target :: Grid
  character(len=*)        :: name_phi
!==============================================================================!

  ! Store grid for which the variable is defined
  phi % pnt_grid => Grid

  ! Store variable name
  phi % name = name_phi

  ! Values in the new (n) and old (o) time step
  allocate (phi % n (Grid % n_faces));  phi % n  = 0.0
  allocate (phi % o (Grid % n_faces));  phi % o  = 0.0
  allocate (phi % oo(Grid % n_faces));  phi % oo = 0.0

  ! Average guessed value, guessed value
  allocate (phi % avg (Grid % n_faces));  phi % avg = 0.0

  end subroutine
