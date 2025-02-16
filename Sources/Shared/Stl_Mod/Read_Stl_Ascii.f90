!==============================================================================!
  subroutine Read_Stl_Ascii(Stl)
!------------------------------------------------------------------------------!
!   Reads an STL file in ASCII format                                          !
!------------------------------------------------------------------------------!
! implicit none
!---------------------------------[Arguments]----------------------------------!
  class(Stl_Type) :: Stl
!-----------------------------------[Locals]-----------------------------------!
  integer :: fu, v, f, i_ver, n
!==============================================================================!

  call File % Open_For_Reading_Ascii(Stl % name, fu)

  !-------------------------------------------------------!
  !   Count all the facets and allocate memory for them   !
  !-------------------------------------------------------!
  rewind(fu)
  f = 0
  do
    call File % Read_Line(fu)
    if(Line % tokens(1) .eq. 'endsolid') exit
    if(Line % tokens(1) .eq. 'facet') f = f + 1
  end do
  if(this_proc < 2) print '(a,i9)', ' # Number of facets on the STL: ', f
  call Stl % Allocate_Stl(f)

  !------------------------------------------------!
  !   Read all facet normals, vertex coordinates   !
  !   and compute facet centroids along the way    !
  !------------------------------------------------!
  rewind(fu)
  f = 0
  do
    call File % Read_Line(fu)
    if(Line % tokens(1) .eq. 'endsolid') exit
    if(Line % tokens(1) .eq. 'facet') then
      f = f - 1
      read(Line % tokens(3), *) Stl % nx(f)
      read(Line % tokens(4), *) Stl % ny(f)
      read(Line % tokens(5), *) Stl % nz(f)
      call File % Read_Line(fu)                ! 'outer loop'
      do i_ver = 1, 3
        v = (abs(f)-1) * 3 + i_ver   ! find global vertex number ...
        Stl % cells_n(i_ver, f) = v  ! ... and store it in facet_v
        call File % Read_Line(fu)              ! 'vertex 1, 2 and 3'
        read(Line % tokens(2), *) Stl % xn(v)
        read(Line % tokens(3), *) Stl % yn(v)
        read(Line % tokens(4), *) Stl % zn(v)
      end do
      call File % Read_Line(fu)                ! 'endloop'
    end if
  end do
  if(this_proc < 2) print '(a)', ' # Read all STL facets!'

  close(fu)

  end subroutine
