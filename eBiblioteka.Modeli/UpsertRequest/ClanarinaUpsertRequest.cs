using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBiblioteka.Modeli.UpsertRequest
{
    public class ClanarinaUpsertRequest
    {
        public string StatusClanarine { get; set; } 

        public DateTime DatumUplate { get; set; }

        public int? KorisnikId { get; set; }

        public int? TipClanarineId { get; set; }
    }
}
