using System;
using System.Collections.Generic;
using System.Text;

namespace eBiblioteka.Modeli.SearchObjects
{
    public class KorisnikSearchObject:BaseSearchObject
    {
        public string? ImeGTE { get; set; }
        public string? PrezimeGTE { get; set; }
        public string? Email { get; set; }
        public string? Telefon { get; set; }
        public string? KorisnickoIme { get; set; }
        public bool? IsBanned { get; set; }
        public int? UlogaId { get; set; }
    }
}
