using System;
using System.Collections.Generic;
using System.Text;

namespace eBiblioteka.Modeli.UpsertRequest
{
    public class KorisnikIzabranaKnjigaUpsertRequest
    {

        public int KnjigaId { get; set; }

        public int KorisnikId { get; set; }

        public DateTime DatumRezervacije { get; set; }

        public DateTime? DatumVracanja { get; set; }

    }
}
