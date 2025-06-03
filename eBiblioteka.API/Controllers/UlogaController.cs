using eBiblioteka.Modeli;
using eBiblioteka.Modeli.DTOs;
using eBiblioteka.Modeli.SearchObjects;
using eBiblioteka.Servisi.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace eBiblioteka.API.Controllers
{
    public class UlogaController : BaseController<UlogaDTO, UlogaSearchObject>
    {
        public UlogaController(IUlogaServis servis) : base(servis)
        {
        }

        [AllowAnonymous]
        public override Task<PagedResult<UlogaDTO>> GetList([FromQuery] UlogaSearchObject searchObject, CancellationToken cancellationToken = default)
        {
            return base.GetList(searchObject, cancellationToken);
        }
    }
}
