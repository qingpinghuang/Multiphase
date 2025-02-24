!==============================================================================!
  subroutine Vof_Initialization_Cylinder(Vof)
!------------------------------------------------------------------------------!
!   Initialize dependent variables.  (It is a bit of a mess still)             !
!------------------------------------------------------------------------------!
  implicit none
!---------------------------------[Arguments]----------------------------------!
  type(Vof_Type), target :: Vof
!-----------------------------------[Locals]-----------------------------------!
  type(Grid_Type),  pointer :: Grid
  integer                   :: c, n, fu
  integer                   :: ee, n_cylinders
  real                      :: radius, height
  real                      :: p1_x, p1_y, p1_z
  real                      :: p2_x, p2_y, p2_z
  real                      :: res_dummy, minnody, maxnody
  real, contiguous, pointer :: prelim_vof(:),min_max_crit_1(:),min_max_crit_2(:)
!==============================================================================!

  call Work % Connect_Real_Cell(prelim_vof, min_max_crit_1, min_max_crit_2)

  ! First take aliasesd
  Grid => Vof % pnt_grid

  prelim_vof = 0.0

  ! call Vof_Init_Random_Seed(problem_name)

  ! Open file to read cylinder parameters:
  call File % Open_For_Reading_Ascii('cylinder_parameters.ini', fu)

  call File % Read_Line(fu)
  read(line % tokens(1), *) n_cylinders

  do ee = 1, n_cylinders

    ! Taking extrema
    min_max_crit_1(:) =  HUGE
    min_max_crit_2(:) = -HUGE

    call File % Read_Line(fu)
    read(line % tokens(1), *) radius

    call File % Read_Line(fu)
    read(line % tokens(1), *) p1_x
    read(line % tokens(2), *) p1_y
    read(line % tokens(3), *) p1_z

    call File % Read_Line(fu)
    read(line % tokens(1), *) p2_x
    read(line % tokens(2), *) p2_y
    read(line % tokens(3), *) p2_z

    height = sqrt((p1_x-p2_x)**2+(p1_y-p2_y)**2+(p1_z-p2_z)**2)

    do c = 1, Grid % n_cells

      ! For every node
      do n = 1, Grid % cells_n_nodes(c)

        res_dummy = (   &
           ( (p2_y-p1_y)*(p1_z-Grid % zn(Grid % cells_n(n,c)))        &
            -(p1_y-Grid % yn(Grid % cells_n(n,c)))*(p2_z-p1_z))**2    &
          +( (p2_x-p1_x)*(p1_z-Grid % zn(Grid % cells_n(n,c)))        &
            -(p1_x-Grid % xn(Grid % cells_n(n,c)))*(p2_z-p1_z))**2    &
          +( (p2_x-p1_x)*(p1_y-Grid % yn(Grid % cells_n(n,c)))        &
            -(p1_x-Grid % xn(Grid % cells_n(n,c)))*(p2_y-p1_y))**2 )  &
          / (radius*height) ** 2

        min_max_crit_1(c)= min(res_dummy, min_max_crit_1(c))
        min_max_crit_2(c)= max(res_dummy, min_max_crit_2(c))
      end do
    end do

    ! Interpolate from exact cylinder
    do c = 1, Grid % n_cells
      call Vof_Exact_Cylinder(Vof,                                  &
                              c,                                     &
                              p1_x, p1_y, p1_z,                      &
                              p2_x, p2_y, p2_z,                      &
                              radius, height,                        &
                              min_max_crit_1(c), min_max_crit_2(c),  &
                              prelim_vof(c))
    end do
    ! Simply interpolate linearly
    ! do c = 1, Grid % n_cells
    !   if (min_max_crit_1(c) < 1.0 .and. min_max_crit_2(c) > 1.0) then
    !       prelim_vof(c) = (1.0 - min_max_crit_1(c))  &
    !                     / (min_max_crit_2(c)-min_max_crit_1(c))
    !   else if (min_max_crit_2(c) <= 1.0) then
    !       prelim_vof(c) = 1.0
    !   end if
    ! end do

    ! Precision
    do c = 1, Grid % n_cells
      Vof % fun % n(c) = max(prelim_vof(c),Vof % fun % n(c))
    end do

  end do

  close(fu)

  call Work % Disconnect_Real_Cell(prelim_vof, min_max_crit_1, min_max_crit_2)

  end subroutine
