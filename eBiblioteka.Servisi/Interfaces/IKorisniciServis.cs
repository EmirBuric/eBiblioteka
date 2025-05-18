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
    public interface IKorisniciServis:ICRUDServis<KorisniciDTO,KorisnikSearchObject,KorisnikInsertRequest,KorisnikUpdateRequest>
    {
        public KorisniciDTO Login(string korisnickoIme, string sifra);
        public Task Ban(int id);
        public Task<string?> GetTrenutnaUloga();
        public Task<int?> GetTrenutniId();
    }
}
