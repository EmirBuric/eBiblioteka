using eBiblioteka.Modeli.DTOs;
using eBiblioteka.Modeli.SearchObjects;
using eBiblioteka.Modeli.UpsertRequest;
using eBiblioteka.Servisi.Interfaces;

namespace eBiblioteka.API.Controllers
{
    public class TerminController : BaseCRUDController<TerminDTO, TerminSearchObject, TerminUpsertRequest, TerminUpsertRequest>
    {
        public TerminController(ITerminServis servis) : base(servis)
        {
        }
    }
}
