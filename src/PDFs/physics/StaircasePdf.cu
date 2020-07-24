#include <goofit/PDFs/physics/StaircasePdf.h>
#include <goofit/PDFs/ParameterContainer.h>
#include <goofit/Variable.h>
#include <goofit/PDFs/GooPdf.h>
#include <goofit/PdfBase.h>

namespace GooFit {

__device__ fptype device_Staircase (fptype* evt, ParameterContainer &pc)
{

  int num_parameters  = pc.getNumParameters();
  int num_constants   = pc.getNumConstants();
  int num_observables = pc.getNumObservables();

  int id       = pc.getObservable(0);
  fptype x     = RO_CACHE(evt[id]);


  fptype ret;
  fptype param;
  for(unsigned int i = 2; i < num_parameters; i++)
  {
    param = pc.getParameter(i);
    if(x < param)
    {
      ret = i;
      break;
    }
  }

  pc.incrementIndex(1, num_parameters, num_constants, num_observables, 1);

  return ret;
}

__device__ device_function_ptr ptr_to_Staircase = device_Staircase;
//device_function_ptr hptr_to_Staircase = device_Staircase;

__host__ StaircasePdf::StaircasePdf(std::string n, Observable _x, std::vector<Variable> x0list)
  : GooPdf("StaircasePdf", n, _x, x0list) 
{
  registerObservable(_x);

  int numParameters = pc.getNumParameters();

  for (i=0;i<numParameters;i++){
    Variable newx0("newx0",0);
    x0list.push_back(newx0);
  }

  for (Variable &x0 : x0list){
    registerParameter(x0);
  }

  registerFunction("ptr_to_Staircase", ptr_to_Staircase);

  initialize();

  //std::cout << "StaircasePdf::StaircasePdf(" << n << ", ...)" << std::endl;
}

} //namespace GooFit