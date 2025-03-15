using eBiblioteka.Modeli.DTOs;
using eBiblioteka.Modeli.SearchObjects;
using eBiblioteka.Modeli.UpsertRequest;
using eBiblioteka.Servisi.Interfaces;

namespace eBiblioteka.API.Controllers
{
    public class RezervacijaController : BaseCRUDController<RezervacijaDTO, RezervacijaSearchObject, RezervacijaUpsertRequest, RezervacijaUpsertRequest>
    {
        public RezervacijaController(IRezervacijaServis servis) : base(servis)
        {
        }
    }
}
