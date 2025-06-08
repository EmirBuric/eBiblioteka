using eBiblioteka.Modeli.DTOs;
using System;
using System.Collections.Generic;
using System.Text;

namespace eBiblioteka.Modeli.SearchObjects
{
    public class RezervacijaSearchObject:BaseSearchObject
    {
        public int? KnjigaId { get; set; }

        public int? KorisnikId { get; set; }

        public DateTime? DatumRezervacijeGTE { get; set; }

        public DateTime? DatumVracanjaGTE { get; set; }

        public bool? Odobrena { get; set; }

        public string? NazivGTE { get; set; }

        public string? ImePrezimeGTE { get; set; }
    }
}
