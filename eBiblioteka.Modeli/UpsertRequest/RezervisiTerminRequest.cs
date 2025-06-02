using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBiblioteka.Modeli.UpsertRequest
{
    public class RezervisiTerminRequest
    {
        public int KorisnikId { get; set; }
        public int TerminId { get; set; }
    }
}
