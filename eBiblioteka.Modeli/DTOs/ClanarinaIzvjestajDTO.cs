using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBiblioteka.Modeli.DTOs
{
    public class ClanarinaIzvjestajDTO
    {
        public double UkupnaZarada { get; set; }

        public List<TipIzvjestajDTO> TipIzvjestaji { get; set; }
    }

    public class TipIzvjestajDTO
    {
        public int TipClanarineId { get; set; }

        public int BrojPoTipu { get; set; }

        public int ZaradaPoTipu { get; set; }
    }
}
