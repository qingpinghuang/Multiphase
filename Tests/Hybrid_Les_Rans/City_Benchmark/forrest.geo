//==============================================================================
//  Create an STL file with:
//
//  gmsh -2 -format stl forrest.geo
//------------------------------------------------------------------------------

SetFactory("OpenCASCADE");
Box(1) = {3, 3, 0, 17, 7, 0.5};
