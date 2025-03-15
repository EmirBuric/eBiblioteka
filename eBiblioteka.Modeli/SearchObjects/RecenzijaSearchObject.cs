using System;
using System.Collections.Generic;
using System.Text;

namespace eBiblioteka.Modeli.SearchObjects
{
    public class RecenzijaSearchObject:BaseSearchObject
    {
        public int? OcjenaGTE { get; set; }

        public int? OcjenaLTE { get; set; }

        public int? KnjigaId { get; set; }

        public int? KorisnikId { get; set; }

        public bool? Odobrena { get; set; }

        public string? NazivGTE { get; set; }

        public string? ImePrezimeGTE { get; set; }
    }
}
