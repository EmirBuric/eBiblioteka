using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBiblioteka.Modeli.SearchObjects
{
    public class ClanarinaSearchObject: BaseSearchObject
    {
        public string? StatusClanarineGTE { get; set; } 

        public DateTime? DatumUplateGTE { get; set; }

        public DateTime? DatumUplateLTE { get; set; }

        public DateTime? DatumIstekaGTE { get; set; }
        public DateTime? DatumIstekaLTE { get; set; }

        public int? TipClanarineId { get; set; }

        public string? ImePrezimeGTE { get; set; }
    }
}
