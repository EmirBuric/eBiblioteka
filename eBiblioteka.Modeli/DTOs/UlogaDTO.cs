using System;
using System.Collections.Generic;
using System.Text;

namespace eBiblioteka.Modeli.DTOs
{
    public class UlogaDTO
    {
        public int UlogaId { get; set; }

        public string Naziv { get; set; } = null!;

        //public virtual ICollection<KorisnikUloga> KorisnikUlogas { get; set; } = new List<KorisnikUloga>();
    }
}
