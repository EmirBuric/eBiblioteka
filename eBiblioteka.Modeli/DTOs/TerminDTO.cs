using System;
using System.Collections.Generic;
using System.Text;

namespace eBiblioteka.Modeli.DTOs
{
    public class TerminDTO
    {
        public int TerminId { get; set; }

        public DateOnly Datum { get; set; }

        public TimeOnly Start { get; set; }

        public TimeOnly Kraj { get; set; }

        public int? KorisnikId { get; set; }

        public bool? JeRezervisan { get; set; }
        public bool? JeProsao { get; set; }

        public int? CitaonicaId { get; set; }

        public virtual KorisniciDTO? Korisnik { get; set; }
    }
}
