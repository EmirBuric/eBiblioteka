using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBiblioteka.Modeli.DTOs
{
    public class KnjigaIzvjestajDTO
    {
        public int KnjigaId { get; set; }
        public string Naziv { get; set; }
        public Dictionary<int, int> RecenzijePoOcjeni { get; set; } = new(); 
        public Dictionary<string, int> RezervacijePoMjesecu { get; set; } = new(); 
        public double ProsjecnaOcjena { get; set; }
    }
}
