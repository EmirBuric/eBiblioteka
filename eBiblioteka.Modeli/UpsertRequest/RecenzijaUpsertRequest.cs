using System;
using System.Collections.Generic;
using System.Text;

namespace eBiblioteka.Modeli.UpsertRequest
{
    public class RecenzijaUpsertRequest
    {
        public int Ocjena { get; set; }

        public string Opis { get; set; }

        public int KnjigaId { get; set; }

        public int KorisnikId { get; set; }
    }
}
