using eBiblioteka.Modeli.DTOs;
using eBiblioteka.Modeli.SearchObjects;
using eBiblioteka.Modeli.UpsertRequest;
using eBiblioteka.Servisi.Interfaces;

namespace eBiblioteka.API.Controllers
{
    public class CitaonicaController : BaseCRUDController<CitaonicaDTO, CitaonicaSearchObject, CitaonicaUpsertRequest, CitaonicaUpsertRequest>
    {
        public CitaonicaController(ICitaonicaServis servis) : base(servis)
        {
        }
    }
}
