!==============================================================================!
  subroutine Save_Poly_Vtu_Binary(Grid)
!------------------------------------------------------------------------------!
!   Writes: name.vtu, name.faces.vtu, name.shadow.vtu                          !
!                                                                              !
!   If you change precision of integers to 64 bits (currently set in the       !
!   makefile and in Const_Mod.f90 with parameter IP), all occurences of        !
!   Int32 here should be changed to Int64.                                     !
!------------------------------------------------------------------------------!
!----------------------------------[Modules]-----------------------------------!
  use Grid_Mod
!------------------------------------------------------------------------------!
  implicit none
!---------------------------------[Arguments]----------------------------------!
  type(Grid_Type) :: Grid
!-----------------------------------[Locals]-----------------------------------!
  integer(SP)     :: data_size
  integer         :: c, n, s, i_pol, data_offset, cell_offset, fu
  integer         :: n_conns, n_polyg
  character(SL)   :: name_out
  character(DL*2) :: str1, str2
!==============================================================================!

  ! Set precision for plotting (intp and floatp variables)
  call Vtk_Mod_Set_Precision()

  ! Count connections in this subdomain, you will need it later
  n_conns = 0
  do c = 1, Grid % n_cells
    n_conns = n_conns + abs(Grid % cells_n_nodes(c))
  end do

  ! Count face data for polyhedral cells, you will need it later
  n_polyg = 0
  do c = 1, Grid % n_cells
    if(Grid % cells_n_nodes(c) .lt. 0) then  ! found a polyhedron
      n_polyg = n_polyg + 1                  ! add one for number of polyfaces
      do i_pol = 1, Grid % cells_n_faces(c)  ! add all faces and their nodes
        s = Grid % cells_f(i_pol, c)
        n = Grid % faces_n_nodes(s)
        n_polyg = n_polyg + 1 + n
      end do
    end if
  end do

  !----------------------!
  !                      !
  !   Create .vtu file   !
  !                      !
  !----------------------!
  call File_Mod_Set_Name(name_out, extension='.vtu')
  call File_Mod_Open_File_For_Writing_Binary(name_out, fu)

  !------------!
  !            !
  !   Header   !
  !            !
  !------------!
  write(fu) IN_0 // '<?xml version="1.0"?>'             // LF
  write(fu) IN_0 // '<VTKFile type="UnstructuredGrid"'  //  &
                    ' version="0.1"'                    //  &
                    ' byte_order="LittleEndian">'       // LF
  write(fu) IN_1 // '<UnstructuredGrid>'                // LF
  write(str1, '(i0.0)') Grid % n_nodes
  write(str2, '(i0.0)') Grid % n_cells
  write(fu) IN_2 // '<Piece NumberOfPoints="' // trim(str1) // '"' //  &
                    ' NumberOfCells="' // trim(str2) // '">'       // LF
  data_offset = 0  ! prepare for the next (the first in this case)

  !-----------!
  !           !
  !   Nodes   !
  !           !
  !-----------!
  write(str1, '(i1)') data_offset
  write(fu) IN_3 // '<Points>'                       // LF
  write(fu) IN_4 // '<DataArray type='//floatp       //  &
                    ' NumberOfComponents="3"'        //  &
                    ' format="appended"'             //  &
                    ' offset="' // trim(str1) //'">' // LF
  write(fu) IN_4 // '</DataArray>' // LF
  write(fu) IN_3 // '</Points>'    // LF
  data_offset = data_offset + SP + Grid % n_nodes * RP * 3  ! prepare for next

  !-----------!
  !           !
  !   Cells   !
  !           !
  !-----------!
  write(fu) IN_3 // '<Cells>' // LF

  ! First write all cells' nodes (a.k.a. connectivity)
  write(str1, '(i0.0)') data_offset
  write(fu) IN_4 // '<DataArray type='//intp         //  &
                    ' Name="connectivity"'           //  &
                    ' format="appended"'             //  &
                    ' offset="' // trim(str1) //'">' // LF
  write(fu) IN_4 // '</DataArray>' // LF
  data_offset = data_offset + SP + n_conns * IP  ! prepare for next

  ! Cells' offsets
  write(str1, '(i0.0)') data_offset
  write(fu) IN_4 // '<DataArray type='//intp         //  &
                    ' Name="offsets"'                //  &
                    ' format="appended"'             //  &
                    ' offset="' // trim(str1) //'">' // LF
  write(fu) IN_4 // '</DataArray>' // LF
  data_offset = data_offset + SP + Grid % n_cells * IP  ! prepare for next

  ! Cells' types
  write(str1, '(i0.0)') data_offset
  write(fu) IN_4 // '<DataArray type='//intp         //  &
                    ' Name="types"'                  //  &
                    ' format="appended"'             //  &
                    ' offset="' // trim(str1) //'">' // LF
  write(fu) IN_4 // '</DataArray>' // LF
  data_offset = data_offset + SP + Grid % n_cells * IP  ! prepare for next

  ! Write polyhedral cells' faces
  write(str1, '(i0.0)') data_offset
  write(fu) IN_4 // '<DataArray type='//intp         //  &
                    ' Name="faces"'                  //  &
                    ' format="appended"'             //  &
                    ' offset="' // trim(str1) //'">' // LF
  write(fu) IN_4 // '</DataArray>' // LF
  data_offset = data_offset + SP + n_polyg * IP  ! prepare for next


  ! Write polyhedral cells' faces offsets
  write(str1, '(i0.0)') data_offset
  write(fu) IN_4 // '<DataArray type='//intp         //  &
                    ' Name="faceoffsets"'            //  &
                    ' format="appended"'             //  &
                    ' offset="' // trim(str1) //'">' // LF
  write(fu) IN_4 // '</DataArray>' // LF
  data_offset = data_offset + SP + Grid % n_cells * IP  ! prepare for next

  write(fu) IN_3 // '</Cells>' // LF

  !---------------!
  !               !
  !   Cell data   !
  !               !
  !---------------!
  write(fu) IN_3 // '<CellData>' // LF

  ! Processor i.d.
  write(str1, '(i0.0)') data_offset
  write(fu) IN_4 // '<DataArray type='//intp         //  &
                    ' Name="Processor"'              //  &
                    ' format="appended"'             //  &
                    ' offset="' // trim(str1) //'">' // LF
  write(fu) IN_4 // '</DataArray>' // LF
  data_offset = data_offset + SP + Grid % n_cells * IP  ! prepare for next

  ! Wall distance
  write(str1, '(i0.0)') data_offset
  write(fu) IN_4 // '<DataArray type='//floatp       //  &
                    ' Name="GeomWallDistance"'       //  &
                    ' format="appended"'             //  &
                    ' offset="' // trim(str1) //'">' // LF
  write(fu) IN_4 // '</DataArray>' // LF
  data_offset = data_offset + SP + Grid % n_cells * RP  ! prepare for next

  ! Cell volume
  write(str1, '(i0.0)') data_offset
  write(fu) IN_4 // '<DataArray type='//floatp       //  &
                    ' Name="GeomCellVolume"'         //  &
                    ' format="appended"'             //  &
                    ' offset="' // trim(str1) //'">' // LF
  write(fu) IN_4 // '</DataArray>' // LF
  data_offset = data_offset + SP + Grid % n_cells * RP  ! prepare for next

  !------------!
  !            !
  !   Footer   !
  !            !
  !------------!
  write(fu) IN_3 // '</CellData>'         // LF
  write(fu) IN_2 // '</Piece>'            // LF
  write(fu) IN_1 // '</UnstructuredGrid>' // LF

  !-------------------!
  !                   !
  !   Appended data   !
  !                   !
  !-------------------!
  write(fu) IN_0 // '<AppendedData encoding="raw">' // LF
  write(fu) '_'

  !-----------!
  !   Nodes   !
  !-----------!
  data_size = Grid % n_nodes * RP * 3
  write(fu) data_size
  do n = 1, Grid % n_nodes
    write(fu) Grid % xn(n), Grid % yn(n), Grid % zn(n)
  end do

  !-----------!
  !   Cells   !
  !-----------!

  ! Cells' nodes
  data_size = n_conns * IP
  write(fu) data_size

  do c = 1, Grid % n_cells

    ! Tetrahedral, pyramid, wedge and hexahedral cells
    if( any( Grid % cells_n_nodes(c) .eq. (/4,5,6,8/)  ) ) then
      write(fu) (Grid % cells_n(1:Grid % cells_n_nodes(c), c))-1

    ! Polyhedral cells
    else if(Grid % cells_n_nodes(c) < 0) then
      write(fu) (Grid % cells_n(1:-Grid % cells_n_nodes(c), c))-1

    else
      print *, '# Unsupported cell type with ',  &
                  Grid % cells_n_nodes(c), ' nodes.'
      print *, '# Exiting'
      stop
    end if
  end do

  ! Cells' offset
  data_size = Grid % n_cells * IP
  write(fu) data_size

  cell_offset = 0
  do c = 1, Grid % n_cells
    cell_offset = cell_offset + abs(Grid % cells_n_nodes(c))
    write(fu) cell_offset
  end do

  ! Cells' types
  data_size = Grid % n_cells * IP
  write(fu) data_size

  do c = 1, Grid % n_cells
    if(Grid % cells_n_nodes(c) .eq. 4) write(fu) VTK_TETRA
    if(Grid % cells_n_nodes(c) .eq. 8) write(fu) VTK_HEXAHEDRON
    if(Grid % cells_n_nodes(c) .eq. 6) write(fu) VTK_WEDGE
    if(Grid % cells_n_nodes(c) .eq. 5) write(fu) VTK_PYRAMID
    if(Grid % cells_n_nodes(c) .lt. 0) write(fu) VTK_POLYHEDRON
  end do

  ! Write polyhedral cells' faces
  data_size = n_polyg * IP
  write(fu) data_size

  do c = 1, Grid % n_cells

    ! You have found a polyhedron, write its faces out
    if(Grid % cells_n_nodes(c) .lt. 0) then

      ! Write number of polyfaces for this cell
      write(fu) Grid % cells_n_faces(c)

      do i_pol = 1, Grid % cells_n_faces(c)
        s = Grid % cells_f(i_pol, c)
        n = Grid % faces_n_nodes(s)
        write(fu) n, (Grid % faces_n(1:n, s))-1
      end do
    end if
  end do

  ! Write polyhedral cells' faces offsets
  data_size = Grid % n_cells * IP
  write(fu) data_size

  cell_offset = 0
  do c = 1, Grid % n_cells

    ! You have found a polyhedron
    if(Grid % cells_n_nodes(c) .lt. 0) then

      ! Increase offset for storing number of polyfaces
      cell_offset = cell_offset + 1

      ! Update the offset with all faces and their nodes
      do i_pol = 1, Grid % cells_n_faces(c)
        s = Grid % cells_f(i_pol, c)
        n = Grid % faces_n_nodes(s)
        cell_offset = cell_offset + 1 + n
      end do

      ! Write the current offset
      write(fu) cell_offset

    ! Not a polyhedron, offsets are not needed
    else
      write(fu) -1
    end if

  end do

  !---------------!
  !   Cell data   !
  !---------------!

  ! Processor i.d.
  data_size = Grid % n_cells * IP
  write(fu) data_size
  do c = 1, Grid % n_cells
    write(fu) Grid % Comm % cell_proc(c)
  end do

  ! Wall distance
  data_size = Grid % n_cells * RP
  write(fu) data_size
  do c = 1, Grid % n_cells
    write(fu) Grid % wall_dist(c)
  end do

  ! Cell volume
  data_size = Grid % n_cells * RP
  write(fu) data_size
  do c = 1, Grid % n_cells
    write(fu) Grid % vol(c)
  end do

  write(fu) LF // IN_0 // '</AppendedData>' // LF

  write(fu) IN_0 // '</VTKFile>' // LF

  !---------------------!
  !                     !
  !   Close .vtu file   !
  !                     !
  !---------------------!
  close(fu)

  end subroutine
