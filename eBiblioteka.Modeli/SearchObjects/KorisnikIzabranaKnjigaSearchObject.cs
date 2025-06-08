using System;
using System.Collections.Generic;
using System.Text;

namespace eBiblioteka.Modeli.SearchObjects
{
    public class KorisnikIzabranaKnjigaSearchObject:BaseSearchObject
    {
        public int? KnjigaIdGTE { get; set; }

        public int? KorisnikIdGTE { get; set; }

        public DateTime? DatumRezervacijeGTE { get; set; }

        public DateTime? DatumVracanjaGTE { get; set; }

        public string? NazivGTE { get; set; }

        public string? ImePrezimeGTE { get; set; }

        public bool? IsChecked { get; set; }
    }
}
