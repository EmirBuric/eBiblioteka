using eBiblioteka.Modeli.DTOs;
using eBiblioteka.Modeli.SearchObjects;
using eBiblioteka.Modeli.UpsertRequest;
using eBiblioteka.Servisi.Interfaces;

namespace eBiblioteka.API.Controllers
{
    public class KnjigaAutorController : BaseCRUDController<KnjigaAutorDTO, KnjigaAutorSearchObject, KnjigaAutorUpsertRequest, KnjigaAutorUpsertRequest>
    {
        public KnjigaAutorController(IKnjigaAutoriServis servis) : base(servis)
        {
        }
    }
}
