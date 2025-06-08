using eBiblioteka.Modeli.DTOs;
using eBiblioteka.Modeli.SearchObjects;
using eBiblioteka.Modeli.UpsertRequest;
using eBiblioteka.Servisi.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace eBiblioteka.API.Controllers
{
    public class KorisnikIzabranaKnjigaController : BaseCRUDController<KorisnikIzabranaKnjigaDTO, KorisnikIzabranaKnjigaSearchObject, KorisnikIzabranaKnjigaUpsertRequest, KorisnikIzabranaKnjigaUpsertRequest>
    {
        public KorisnikIzabranaKnjigaController(IKorisnikIzabranaKnjigaServis servis) : base(servis)
        {
        }

        [HttpPut("UpdateIsCheckedList")]
        public async Task UpdateIsCheckedList(List<int> isCheckedIdsList)
        {
            await (_servis as IKorisnikIzabranaKnjigaServis).UpdateIsCheckedList(isCheckedIdsList);
        }

        [HttpPut("UpdateIsChecked/{isCheckedId}")]
        public async Task UpdateIsChecked(int isCheckedId)
        {
            await (_servis as IKorisnikIzabranaKnjigaServis).UpdateIsChecked(isCheckedId);
        }
    }
}
