using System;
using System.Collections.Generic;
using System.Text;

namespace eBiblioteka.Modeli.DTOs
{
    public class KorisnikIzabranaKnjigaDTO
    {
        public int KorisnikIzabranaKnjigaId { get; set; }

        public int KnjigaId { get; set; }

        public int KorisnikId { get; set; }

        public bool IsChecked { get; set; }

        public DateTime DatumRezervacije { get; set; }

        public DateTime DatumVracanja { get; set; }

        public virtual KorisniciDTO? Korisnik { get; set; } 

        public virtual KnjigaDTO? Knjiga { get; set; } 
    }
}
