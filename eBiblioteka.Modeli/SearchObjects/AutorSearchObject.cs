using System;
using System.Collections.Generic;
using System.Text;

namespace eBiblioteka.Modeli.SearchObjects
{
    public class AutorSearchObject:BaseSearchObject
    {
        public string? ImeGTE { get; set; }
        public string? PrezimeGTE { get; set; }
        public int? GodinaRodjenjaGTE { get; set; }
        public int? GodinaRodjenjaLTE { get; set; }
    }
}
