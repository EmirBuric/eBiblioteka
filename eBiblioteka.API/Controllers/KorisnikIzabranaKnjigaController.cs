using eBiblioteka.Modeli.DTOs;
using eBiblioteka.Modeli.SearchObjects;
using eBiblioteka.Modeli.UpsertRequest;
using eBiblioteka.Servisi.Interfaces;

namespace eBiblioteka.API.Controllers
{
    public class KorisnikIzabranaKnjigaController : BaseCRUDController<KorisnikIzabranaKnjigaDTO, KorisnikIzabranaKnjigaSearchObject, KorisnikIzabranaKnjigaUpsertRequest, KorisnikIzabranaKnjigaUpsertRequest>
    {
        public KorisnikIzabranaKnjigaController(IKorisnikIzabranaKnjigaServis servis) : base(servis)
        {
        }
    }
}
