!==============================================================================!
  subroutine Form_Maps(Grid)
!------------------------------------------------------------------------------!
!   Forms maps for parallel backup                                             !
!------------------------------------------------------------------------------!
  implicit none
!---------------------------------[Arguments]----------------------------------!
  class(Grid_Type) :: Grid
!-----------------------------------[Locals]-----------------------------------!
  integer :: c, cnt
!==============================================================================!
!   There is an issue with this procedure, but it's more related to MPI/IO     !
!   functions than T-Flows.  In cases a subdomain has no physical boundary     !
!   cells, variable "nb_sub" turns out to be zero.  This, per se, should not   !
!   be an issue if MPI/IO functions could handle calls to:                     !
!   "Mpi_Type_Create_Indexed_Block(...)" and "Mpi_File_Write(...)" with zero   !
!   length.  But they don't.  Therefore, I avoid allocation with zero size     !
!   (max(nb_sub,1)) here and creation of new types with zero size in           !
!   "Comm_Mod_Create_New_Types".  It is a bit of a dirty trick :-(             !
!------------------------------------------------------------------------------!

  ! Initialize number of cells in subdomain
  Grid % Comm % nc_sub = Grid % n_cells - Grid % Comm % n_buff_cells

  ! Initialize number of boundary cells in subdomain
  Grid % Comm % nb_sub = 0
  do c = -Grid % n_bnd_cells, -1
    if(Grid % Comm % cell_proc(c) .eq. this_proc) then
      Grid % Comm % nb_sub = Grid % Comm % nb_sub + 1
    end if
  end do

  ! First and last cell to send
  Grid % Comm % nb_f = Grid % n_bnd_cells
  Grid % Comm % nb_l = Grid % n_bnd_cells - Grid % Comm % nb_sub + 1

  ! Initialize total number of cells
  Grid % Comm % nc_tot = Grid % Comm % nc_sub
  Grid % Comm % nb_tot = Grid % Comm % nb_sub
  call Comm_Mod_Global_Sum_Int(Grid % Comm % nc_tot)
  call Comm_Mod_Global_Sum_Int(Grid % Comm % nb_tot)

  ! Allocate memory for mapping matrices
  allocate(Grid % Comm % cell_map        (Grid % Comm % nc_sub))
  allocate(Grid % Comm % bnd_cell_map(max(Grid % Comm % nb_sub,1)))
  Grid % Comm % cell_map(:)         = 0
  Grid % Comm % bnd_cell_map(:)     = 0

  !--------------------------------!
  !                                !
  !   For run with one processor   !
  !                                !
  !--------------------------------!
  if(n_proc < 2) then

    !-------------------------------------!
    !   Global cell numbers for T-Flows   !
    !-------------------------------------!
    do c = -Grid % Comm % nb_tot, Grid % Comm % nc_tot
      Grid % Comm % cell_glo(c) = c
    end do

    !-----------------------------!
    !   Create mapping matrices   !
    !-----------------------------!

    ! -1 is to start from zero, as needed by MPI functions
    do c = 1, Grid % Comm % nc_tot
      Grid % Comm % cell_map(c) = int(c-1, SP)
    end do

    ! -1 is to start from zero, as needed by MPI functions
    do c = 1, Grid % Comm % nb_tot
      Grid % Comm % bnd_cell_map(c) = int(c-1, SP)
    end do

  !-----------------------!
  !                       !
  !   For parallel runs   !
  !                       !
  !-----------------------!
  else

    !-----------------------------!
    !   Create mapping matrices   !
    !-----------------------------!

    !---------------------!
    !   Inside cell map   !
    !---------------------!
    do c = 1, Grid % Comm % nc_sub
      ! Take cell mapping to be the same as global cell numbers but start from 0
      Grid % Comm % cell_map(c) = int(Grid % Comm % cell_glo(c)-1, SP)
    end do

    !-----------------------!
    !   Boundary cell map   !
    !-----------------------!
    cnt = 0
    do c = -Grid % Comm % nb_f, -Grid % Comm % nb_l
      cnt = cnt + 1
      Grid % Comm % bnd_cell_map(cnt) = int(  Grid % Comm % cell_glo(c)  &
                                            + Grid % Comm % nb_tot, SP)
    end do

    ! If domain has zero boundary cells, make the only
    ! (fictitious) member in the map point it to zero.
    if(cnt .eq. 0) then
      Grid % Comm % bnd_cell_map(1) = int(0, SP)
      Grid % Comm % nb_f = 0
      Grid % Comm % nb_l = 0
    end if

  end if

  end subroutine
