!==============================================================================!
  subroutine Grid_Topology(Convert, Grid)
!------------------------------------------------------------------------------!
!   Determines the topology of the Grid.                                       !
!
!   To be more specific, it determines:
!                                                                              !
!   Grid % n_bnd_cells   - number of boundary cells                            !
!   Grid % cells_n_nodes - number of nodes for each cell                       !
!   Grid % cells_n       - list of each cell's nodes                           !
!   Grid % n_faces       - number of faces on the boundary                     !
!   Grid % faces_n_nodes - number of nodes for each face on the boundary       !
!   Grid % faces_n       - list of each boundary face's nodes                  !
!   Grid % faces_c       - a pair of cells surrounding each boundary face      !
!------------------------------------------------------------------------------!
  implicit none
!---------------------------------[Arguments]----------------------------------!
  class(Convert_Type) :: Convert
  type(Grid_Type)     :: Grid
!-----------------------------------[Locals]-----------------------------------!
  integer :: i, j
!==============================================================================!

  call Profiler % Start('Grid_Topology')

  !------------------------------!
  !   Count the boundary cells   !
  !------------------------------!
  Grid % n_bnd_cells = 0
  Grid % n_faces  = 0
  do i = 1, Grid % n_cells
    do j = 1, 6
      if(Grid % cells_bnd_color(j,i) .ne. 0) then

        Grid % n_bnd_cells = Grid % n_bnd_cells + 1

        ! Grid % bnd_cond % color
        Grid % bnd_cond % color(-Grid % n_bnd_cells) =   &
                                                    Grid % cells_bnd_color(j,i)
        ! Faces
        Grid % n_faces = Grid % n_faces  + 1
        Grid % faces_c(1,Grid % n_faces) = i
        Grid % faces_c(2,Grid % n_faces) = -Grid % n_bnd_cells

        ! Hexahedra:
        if(Grid % cells_n_nodes(i) .eq. 8) then
          Grid % cells_n_nodes(-Grid % n_bnd_cells) = 4
          Grid % cells_n(1,-Grid % n_bnd_cells) = Grid % cells_n(HEX(j,1),i)
          Grid % cells_n(2,-Grid % n_bnd_cells) = Grid % cells_n(HEX(j,2),i)
          Grid % cells_n(3,-Grid % n_bnd_cells) = Grid % cells_n(HEX(j,3),i)
          Grid % cells_n(4,-Grid % n_bnd_cells) = Grid % cells_n(HEX(j,4),i)

          Grid % faces_n_nodes(Grid % n_faces) = 4
          call Adjust_First_Dim(4, Grid % faces_n)
          call Adjust_First_Dim(4, Grid % cells_n)
          Grid % faces_n(1:4, Grid % n_faces)  =   &
          Grid % cells_n(1:4,-Grid % n_bnd_cells)

        ! Prisms:
        else if(Grid % cells_n_nodes(i) .eq. 6) then
          if(j <= 3) then    ! faces (1), (2) and (3)
            Grid % cells_n_nodes(-Grid % n_bnd_cells) = 4
            Grid % cells_n(1,-Grid % n_bnd_cells)=Grid % cells_n(WED(j,1),i)
            Grid % cells_n(2,-Grid % n_bnd_cells)=Grid % cells_n(WED(j,2),i)
            Grid % cells_n(3,-Grid % n_bnd_cells)=Grid % cells_n(WED(j,3),i)
            Grid % cells_n(4,-Grid % n_bnd_cells)=Grid % cells_n(WED(j,4),i)

            Grid % faces_n_nodes(Grid % n_faces) = 4
            call Adjust_First_Dim(4, Grid % faces_n)
            call Adjust_First_Dim(4, Grid % cells_n)
            Grid % faces_n(1:4, Grid % n_faces)  =   &
            Grid % cells_n(1:4,-Grid % n_bnd_cells)

          else if(j <= 5) then
            Grid % cells_n_nodes(-Grid % n_bnd_cells) = 3
            Grid % cells_n(1,-Grid % n_bnd_cells)=Grid % cells_n(WED(j,1),i)
            Grid % cells_n(2,-Grid % n_bnd_cells)=Grid % cells_n(WED(j,2),i)
            Grid % cells_n(3,-Grid % n_bnd_cells)=Grid % cells_n(WED(j,3),i)

            Grid % faces_n_nodes(Grid % n_faces) = 3
            call Adjust_First_Dim(3, Grid % faces_n)
            call Adjust_First_Dim(3, Grid % cells_n)
            Grid % faces_n(1:3, Grid % n_faces)  =   &
            Grid % cells_n(1:3,-Grid % n_bnd_cells)
          end if

        ! Tetrahedra:
        else if(Grid % cells_n_nodes(i) .eq. 4) then
          if(j <= 4) then
            Grid % cells_n_nodes(-Grid % n_bnd_cells) = 3
            Grid % cells_n(1,-Grid % n_bnd_cells)=Grid % cells_n(TET(j,1),i)
            Grid % cells_n(2,-Grid % n_bnd_cells)=Grid % cells_n(TET(j,2),i)
            Grid % cells_n(3,-Grid % n_bnd_cells)=Grid % cells_n(TET(j,3),i)

            Grid % faces_n_nodes(Grid % n_faces) = 3
            call Adjust_First_Dim(3, Grid % faces_n)
            call Adjust_First_Dim(3, Grid % cells_n)
            Grid % faces_n(1:3, Grid % n_faces)  =   &
            Grid % cells_n(1:3,-Grid % n_bnd_cells)
          end if

        ! Pyramides:
        else if(Grid % cells_n_nodes(i) .eq. 5) then
          if(j .eq. 1) then    ! face (1)
            Grid % cells_n_nodes(-Grid % n_bnd_cells) = 4
            Grid % cells_n(1,-Grid % n_bnd_cells)=Grid % cells_n(PYR(j,1),i)
            Grid % cells_n(2,-Grid % n_bnd_cells)=Grid % cells_n(PYR(j,2),i)
            Grid % cells_n(3,-Grid % n_bnd_cells)=Grid % cells_n(PYR(j,3),i)
            Grid % cells_n(4,-Grid % n_bnd_cells)=Grid % cells_n(PYR(j,4),i)

            Grid % faces_n_nodes(Grid % n_faces) = 4
            call Adjust_First_Dim(4, Grid % faces_n)
            call Adjust_First_Dim(4, Grid % cells_n)
            Grid % faces_n(1:4, Grid % n_faces)  =   &
            Grid % cells_n(1:4,-Grid % n_bnd_cells)

          else if(j <= 5) then
            Grid % cells_n_nodes(-Grid % n_bnd_cells) = 3
            Grid % cells_n(1,-Grid % n_bnd_cells)=Grid % cells_n(PYR(j,1),i)
            Grid % cells_n(2,-Grid % n_bnd_cells)=Grid % cells_n(PYR(j,2),i)
            Grid % cells_n(3,-Grid % n_bnd_cells)=Grid % cells_n(PYR(j,3),i)

            Grid % faces_n_nodes(Grid % n_faces) = 3
            call Adjust_First_Dim(3, Grid % faces_n)
            call Adjust_First_Dim(3, Grid % cells_n)
            Grid % faces_n(1:3, Grid % n_faces)  =   &
            Grid % cells_n(1:3,-Grid % n_bnd_cells)
          end if

        else
          print *, '# Cell with invalid number of nodes: ',  &
                   Grid % cells_n_nodes(i)
          print *, '# Exiting!'
          stop
        end if

      end if
    end do
  end do

  print '(a38,i9)', '# Number of boundary cells:          ', Grid % n_bnd_cells
  print '(a38,i9)', '# Number of faces on the boundary:   ', Grid % n_faces

  call Profiler % Stop('Grid_Topology')

  end subroutine
