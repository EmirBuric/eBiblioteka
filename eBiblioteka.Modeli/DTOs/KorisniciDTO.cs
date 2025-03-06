using System;
using System.Collections.Generic;
using System.Text;

namespace eBiblioteka.Modeli.DTOs
{
    public class KorisniciDTO
    {
        public int KorisnikId { get; set; }

        public string Ime { get; set; } = null!;

        public string Prezime { get; set; } = null!;

        public string Email { get; set; } = null!;

        public string? Telefon { get; set; }

        public string KorisnickoIme { get; set; } = null!;

        public virtual ICollection<KorisniciUlogeDTO> KorisnikUlogas { get; set; } = new List<KorisniciUlogeDTO>();
    }
}
