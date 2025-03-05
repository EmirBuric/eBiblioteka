using eBiblioteka.Modeli.DTOs;
using eBiblioteka.Modeli.SearchObjects;
using eBiblioteka.Servisi.Interfaces;

namespace eBiblioteka.API.Controllers
{
    public class TipClanarineController : BaseController<TipClanarineDTO, TipClanarineSearchObject>
    {
        public TipClanarineController(ITipClanarineServis servis) : base(servis)
        {
        }
    }
}
