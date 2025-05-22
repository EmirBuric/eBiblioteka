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

        public string? Autor { get; set; }

        public bool? KnjigaDana { get; set; }

    }
}
