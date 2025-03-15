using System;
using System.Collections.Generic;
using System.Text;

namespace eBiblioteka.Modeli.DTOs
{
    public class RecenzijaDTO
    {
        public int RecenzijaId { get; set; }

        public int Ocjena { get; set; }

        public string Opis { get; set; }

        public int KnjigaId { get; set; }

        public int KorisnikId { get; set; }

        public bool Odobrena { get; set; }

        public DateTime DatumRecenzije { get; set; }

        public KorisniciDTO? Korisnik { get; set; }

        public KnjigaDTO? Knjiga { get; set; }
    }
}
