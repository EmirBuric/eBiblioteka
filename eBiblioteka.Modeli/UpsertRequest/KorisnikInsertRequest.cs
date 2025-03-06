using System;
using System.Collections.Generic;
using System.Text;

namespace eBiblioteka.Modeli.UpsertRequest
{
    public class KorisnikInsertRequest
    {
        public string Ime { get; set; } 

        public string Prezime { get; set; } 

        public string Email { get; set; } 

        public string Telefon { get; set; }

        public string KorisnickoIme { get; set; } 

        public string Lozinka { get; set; } 
        public string LozinkaPotvrda { get; set; }

        public List<int> Uloge { get; set; }
    }
}
