!==============================================================================!
  subroutine Mass_Transfer_Estimate(Vof)
!------------------------------------------------------------------------------!
!   Calculates pressure source due to phase change                             !
!                                                                              !
!   Called from Multiphase_Mod_Vof_Pressure_Correction                         !
!------------------------------------------------------------------------------!
  implicit none
!---------------------------------[Arguments]----------------------------------!
  class(Vof_Type), target :: Vof
!------------------------------[Local parameters]------------------------------!
  logical, parameter :: DEBUG = .false.
!-----------------------------------[Locals]-----------------------------------!
  type(Grid_Type),  pointer :: Grid
  type(Field_Type), pointer :: Flow
  type(Var_Type),   pointer :: t
  integer                   :: e, s, c1, c2, i_ele
  real                      :: cond_1, cond_2
!==============================================================================!

  ! Take aliases
  Grid => Vof % pnt_grid
  Flow => Vof % pnt_flow
  t    => Flow % t

  ! If not a problem with mass transfer, get out of here
  if(.not. Flow % mass_transfer) return

  ! Initialize mass transfer term
  Vof % m_dot(:) = 0.0

  !------------------------------------------------!
  !   Compute gradients of temperature, imposing   !
  !    saturation temperature at the interface     !
  !------------------------------------------------!
  call Vof % Grad_Variable_With_Front(t, Vof % t_sat)
  if(DEBUG) then
    call Grid % Save_Debug_Vtu("grad-t",                               &
                               scalar_cell = t % n,                    &
                               scalar_name = "t",                      &
                               vector_cell = (/t % x, t % y, t % z/),  &
                               vector_name = "grad-t")
  end if

  !----------------------------------------!
  !   Compute heat flux at the interface   !
  !----------------------------------------!
  do s = 1, Grid % n_faces

    c1 = Grid % faces_c(1,s)
    c2 = Grid % faces_c(2,s)

    if(any(Vof % Front % elems_at_face(1:2,s) .ne. 0)) then

      Vof % q_int(1,s) = 0.0
      Vof % q_int(2,s) = 0.0

      do i_ele = 1, 2
        e = Vof % Front % elems_at_face(i_ele, s)
        if(e .ne. 0) then

          ! Take conductivities from each side of the interface
          cond_1 = Vof % phase_cond(1)
          cond_2 = Vof % phase_cond(0)
          if(Vof % fun % n(c1) < 0.5) cond_1 = Vof % phase_cond(0)
          if(Vof % fun % n(c2) > 0.5) cond_2 = Vof % phase_cond(1)

          ! Compute heat fluxes from each side of the interface
          ! Keep in mind that in the Stefan's case, dot product of
          ! element's surface and face's surface is positive.  If
          ! VOF's definition changes, I assume this would have to
          ! be adjusted accordingly.
          ! Units: W/(mK) * K/m * m^2 = W
          Vof % q_int(1,s) = Vof % q_int(1,s)                               &
              + cond_1 * (  t % x(c1) * Vof % Front % elem(e) % sx   &
                          + t % y(c1) * Vof % Front % elem(e) % sy   &
                          + t % z(c1) * Vof % Front % elem(e) % sz)

          Vof % q_int(2,s) = Vof % q_int(2,s)                               &
              + cond_2 * (  t % x(c2) * Vof % Front % elem(e) % sx   &
                          + t % y(c2) * Vof % Front % elem(e) % sy   &
                          + t % z(c2) * Vof % Front % elem(e) % sz)

        end if  ! e .ne. 0
      end do    ! i_ele

      ! Accumulate sources in the cells surroundig the face
      ! Unit: W * kg/J = kg / s
      if(Vof % Front % elem_in_cell(c1) .ne. 0) then
        Vof % m_dot(c1) =  Vof % m_dot(c1)                       &
                        + (Vof % q_int(2,s) - Vof % q_int(1,s))  &
                        / 2.26e+6
      end if

      if(Vof % Front % elem_in_cell(c2) .ne. 0) then
        Vof % m_dot(c2) =  Vof % m_dot(c2)                       &
                        + (Vof % q_int(2,s) - Vof % q_int(1,s))  &
                        / 2.26e+6
      end if

    end if      ! face is at the front

  end do

  end subroutine
