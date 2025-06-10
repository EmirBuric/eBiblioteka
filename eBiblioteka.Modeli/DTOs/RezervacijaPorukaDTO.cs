using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBiblioteka.Modeli.DTOs
{
    public class RezervacijaPorukaDTO
    {
        public string KorisnikEmail { get; set; }
        public string KorisnikIme { get; set; }
        public string KorisnikPrezime { get; set; }
        public string NazivKnjige { get; set; }
        public DateTime DatumOd { get; set; }
        public DateTime? DatumDo { get; set; }
        public bool Odobrena { get; set; }
        public string TipPoruke { get; set; }
    }
}
