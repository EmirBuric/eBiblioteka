using System;
using System.Collections.Generic;
using System.Text;

namespace eBiblioteka.Modeli.DTOs
{
    public class RezervacijaDTO
    {
        public int RezervacijaId { get; set; }

        public int KnjigaId { get; set; }

        public int KorisnikId { get; set; }

        public DateTime DatumRezervacije { get; set; }

        public DateTime DatumVracanja { get; set; }

        public bool Odobrena { get; set; }

        public bool Pregledana { get; set; }

        public KnjigaDTO? Knjiga { get; set; }

        public KorisniciDTO? Korisnik { get; set; }
    }
}
