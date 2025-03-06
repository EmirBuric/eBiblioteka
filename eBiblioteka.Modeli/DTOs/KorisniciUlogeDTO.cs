using System;
using System.Collections.Generic;
using System.Text;

namespace eBiblioteka.Modeli.DTOs
{
    public class KorisniciUlogeDTO
    {
        public int KorisnikUlogaId { get; set; }

        public int? KorisnikId { get; set; }

        public int? UlogaId { get; set; }

        public virtual UlogaDTO? Uloga { get; set; }
    }
}
