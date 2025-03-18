using eBiblioteka.Modeli.DTOs;
using eBiblioteka.Modeli.SearchObjects;
using eBiblioteka.Modeli.UpsertRequest;
using eBiblioteka.Servisi.Interfaces;

namespace eBiblioteka.API.Controllers
{
    public class ClanarinaController : BaseCRUDController<ClanarinaDTO, ClanarinaSearchObject, ClanarinaUpsertRequest, ClanarinaUpsertRequest>
    {
        public ClanarinaController(IClanarinaServis servis) : base(servis)
        {
        }
    }
}
