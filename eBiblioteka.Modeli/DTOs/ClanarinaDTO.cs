using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBiblioteka.Modeli.DTOs
{
    public class ClanarinaDTO
    {
        public int ClanarinaId { get; set; }

        public string StatusClanarine { get; set; } 

        public DateTime DatumUplate { get; set; }

        public DateTime DatumIsteka { get; set; }

        public int? KorisnikId { get; set; }

        public int? TipClanarineId { get; set; }

        public virtual KorisniciDTO? Korisnik { get; set; }
    }
}
