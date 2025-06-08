using eBiblioteka.Modeli.DTOs;
using eBiblioteka.Modeli.SearchObjects;
using eBiblioteka.Modeli.UpsertRequest;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBiblioteka.Servisi.Interfaces
{
    public interface IKorisnikIzabranaKnjigaServis:ICRUDServis<KorisnikIzabranaKnjigaDTO,KorisnikIzabranaKnjigaSearchObject, KorisnikIzabranaKnjigaUpsertRequest,KorisnikIzabranaKnjigaUpsertRequest>
    {
        public Task UpdateIsCheckedList(List<int> isCheckedIdsList);
        public Task UpdateIsChecked(int isCheckedId);
    }
}
