!==============================================================================!
  module Numerics_Mod
!------------------------------------------------------------------------------!
!   Module which embodies subroutines and function typical for numerical       !
!   treatment of dicretized equations.  It should lead to reduction of code    !
!   duplication for routinely used procedures.                                 !
!   terms and diffusion terms.                                                 !
!                                                                              !
!   (It is also the first module which has all "use" statements here, in       !
!    the definition of the module itself.  That's a better practice than to
!    have them spread over included functions.)                                !
!------------------------------------------------------------------------------!
!----------------------------------[Modules]-----------------------------------!
  use Matrix_Mod
  use Var_Mod
  use Work_Mod
!------------------------------------------------------------------------------!
  implicit none
!==============================================================================!

  ! Parameters for advection scheme
  integer, parameter :: UPWIND    = 40009
  integer, parameter :: CENTRAL   = 40013
  integer, parameter :: LUDS      = 40031
  integer, parameter :: QUICK     = 40037
  integer, parameter :: SMART     = 40039
  integer, parameter :: GAMMA     = 40063
  integer, parameter :: MINMOD    = 40087
  integer, parameter :: BLENDED   = 40093
  integer, parameter :: SUPERBEE  = 40099
  integer, parameter :: AVL_SMART = 40111
  integer, parameter :: CICSAM    = 40123
  integer, parameter :: STACS     = 40127

  ! Time integration parameters
  integer, parameter :: LINEAR        = 40129
  integer, parameter :: PARABOLIC     = 40151
  integer, parameter :: RUNGE_KUTTA_3 = 40153

  ! Algorithms for pressure velocity coupling
  integer, parameter :: SIMPLE = 40163
  integer, parameter :: PISO   = 40169
  integer, parameter :: CHOI   = 40177

  ! Gradient computation algorithms
  integer, parameter :: LEAST_SQUARES = 40189
  integer, parameter :: GAUSS_THEOREM = 40193

  contains

#   include "Numerics_Mod/Advection_Scheme.f90"
#   include "Numerics_Mod/Advection_Scheme_Code.f90"
#   include "Numerics_Mod/Advection_Term.f90"
#   include "Numerics_Mod/Gradient_Method_Code.f90"
#   include "Numerics_Mod/Inertial_Term.f90"
#   include "Numerics_Mod/Min_Max.f90"
#   include "Numerics_Mod/Pressure_Momentum_Coupling_Code.f90"
#   include "Numerics_Mod/Time_Integration_Scheme_Code.f90"
#   include "Numerics_Mod/Under_Relax.f90"

  end module
