!==============================================================================!
  module Math_Mod
!------------------------------------------------------------------------------!
!   This module contains some basic mathematical (and related) functions       !
!------------------------------------------------------------------------------!
!----------------------------------[Modules]-----------------------------------!
  use Const_Mod
!------------------------------------------------------------------------------!
  implicit none
!==============================================================================!

  ! Default precision for "Approx_Real" and "Smaller_Real" functions
  real, parameter :: DEFAULT_TOLERANCE = NANO

  !---------------!
  !   Math type   !
  !---------------!
  type Math_Type

    contains
      procedure          :: Approx_Real
      procedure          :: Approx_String
      procedure          :: Cross_Product
      procedure          :: Distance
      procedure          :: Distance_Squared
      procedure          :: Fit_Exp_Derivative_And_Two_Points
      procedure          :: Fit_Exp_Three_Points
      procedure          :: Gaussian_Elimination
      procedure          :: Harmonic_Mean
      procedure          :: Invert_3x3_Matrix
      procedure          :: Rotate_Vector
      procedure, private :: Set_Array_Range
      procedure          :: Signed_Lower_Limit
      procedure          :: Signed_Upper_Limit
      procedure          :: Smaller_Real
      procedure          :: Tet_Inertia
      procedure          :: Tet_Volume

  end type

  !--------------------------------------!
  !   Create one instance of Math type   !
  !     for all other modules to use     !
  !--------------------------------------!
  type(Math_Type) :: Math

  contains

#   include "Math_Mod/Approx_Real.f90"
#   include "Math_Mod/Approx_String.f90"
#   include "Math_Mod/Cross_Product.f90"
#   include "Math_Mod/Distance.f90"
#   include "Math_Mod/Distance_Squared.f90"
#   include "Math_Mod/Fit_Exp_Derivative_And_Two_Points.f90"
#   include "Math_Mod/Fit_Exp_Three_Points.f90"
#   include "Math_Mod/Gaussian_Elimination.f90"
#   include "Math_Mod/Harmonic_Mean.f90"
#   include "Math_Mod/Invert_3x3_Matrix.f90"
#   include "Math_Mod/Rotate_Vector.f90"
#   include "Math_Mod/Set_Array_Range.f90"
#   include "Math_Mod/Signed_Lower_Limit.f90"
#   include "Math_Mod/Signed_Upper_Limit.f90"
#   include "Math_Mod/Smaller_Real.f90"
#   include "Math_Mod/Tet_Inertia.f90"
#   include "Math_Mod/Tet_Volume.f90"

  end module
