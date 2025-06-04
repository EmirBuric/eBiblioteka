using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBiblioteka.Modeli.DTOs
{
    public class DostupnostKnjigeDTO
    {
        public int KnjigaId { get; set; }

        public Dictionary<DateTime, bool> Dostupnost { get; set; } = new();
    }
}
