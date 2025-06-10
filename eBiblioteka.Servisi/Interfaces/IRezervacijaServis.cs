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
    public interface IRezervacijaServis:ICRUDServis<RezervacijaDTO,RezervacijaSearchObject,RezervacijaUpsertRequest,RezervacijaUpsertRequest>
    {
        public Task PotvrdiRezervaciju(int id, bool potvrda);
        public Task PosaljiPoruku(RezervacijaPorukaDTO poruka);
    }
}
