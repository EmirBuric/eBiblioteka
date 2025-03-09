using eBiblioteka.Modeli.DTOs;
using eBiblioteka.Modeli.SearchObjects;
using eBiblioteka.Modeli.UpsertRequest;
using eBiblioteka.Servisi.Interfaces;

namespace eBiblioteka.API.Controllers
{
    public class KnjigaController : BaseCRUDController<KnjigaDTO, KnjigaSearchObject, KnjigaInsertRequest, KnjigaUpdateRequest>
    {
        public KnjigaController(IKnjigaServis servis) : base(servis)
        {
        }
    }
}
