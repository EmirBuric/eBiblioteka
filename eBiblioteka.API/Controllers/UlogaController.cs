using eBiblioteka.Modeli.DTOs;
using eBiblioteka.Modeli.SearchObjects;
using eBiblioteka.Servisi.Interfaces;

namespace eBiblioteka.API.Controllers
{
    public class UlogaController : BaseController<UlogaDTO, UlogaSearchObject>
    {
        public UlogaController(IUlogaServis servis) : base(servis)
        {
        }
    }
}
