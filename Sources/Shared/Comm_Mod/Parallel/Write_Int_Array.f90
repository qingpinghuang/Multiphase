!==============================================================================!
  subroutine Write_Int_Array(Comm, fh, arr, disp)
!------------------------------------------------------------------------------!
!   Write integer array for parallel runs.                                     !
!------------------------------------------------------------------------------!
  implicit none
!---------------------------------[Arguments]----------------------------------!
  class(Comm_Type)      :: Comm
  type(Mpi_File)        :: fh    ! file handle
  integer, dimension(:) :: arr   ! array to write out
  integer(DP)           :: disp  ! displacement in bytes
!-----------------------------------[Locals]-----------------------------------!
  integer :: length
  integer :: error = 0
!==============================================================================!

  ! Get array's length
  length = size(arr)

  ! Set it at position disp (same as in Read counterpart)
  call Mpi_File_Set_View(fh,             &
                         disp,           &
                         comm_type_int,  &
                         comm_type_int,  &
                         'native',       &
                         MPI_INFO_NULL,  &
                         error)

  ! Write integer value 
  call Mpi_File_Write(fh,                 &
                      arr(1),             &
                      length,             &
                      comm_type_int,      &
                      MPI_STATUS_IGNORE,  &
                      error)

  disp = disp + IP * length

  end subroutine
