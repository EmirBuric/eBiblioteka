using System;
using System.Collections.Generic;
using System.Text;

namespace eBiblioteka.Modeli.SearchObjects
{
    public class KnjigaSearchObject:BaseSearchObject
    {
        public string? NazivGTE { get; set; } = null!;

        public int? GodinaIzdanjaGTE { get; set; }

        public int? GodinaIzdanjaLTE { get; set; }

        public int? ZanrId { get; set; }

        public int? KolicinaGTE { get; set; }

        public int? AutorId { get; set; }

        public bool? KnjigaDana { get; set; }

        public bool? Preporuceno { get; set; }

    }
}
