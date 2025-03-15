using eBiblioteka.Modeli.DTOs;
using eBiblioteka.Modeli.SearchObjects;
using eBiblioteka.Modeli.UpsertRequest;
using eBiblioteka.Servisi.Interfaces;

namespace eBiblioteka.API.Controllers
{
    public class RecenzijaController : BaseCRUDController<RecenzijaDTO, RecenzijaSearchObject, RecenzijaUpsertRequest, RecenzijaUpsertRequest>
    {
        public RecenzijaController(IRecenzijaServis servis) : base(servis)
        {
        }
    }
}
