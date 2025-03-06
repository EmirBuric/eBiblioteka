using System;
using System.Collections.Generic;
using System.Text;

namespace eBiblioteka.Modeli.UpsertRequest
{
    public class KorisnikUpdateRequest
    {
        public string Ime { get; set; } 

        public string Prezime { get; set; } 

        public string? Telefon { get; set; }

        public string Lozinka { get; set; } 
        public string LozinkaPotvrda { get; set; } 
    }
}
