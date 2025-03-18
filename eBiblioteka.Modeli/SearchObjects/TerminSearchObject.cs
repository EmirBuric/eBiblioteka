using System;
using System.Buffers.Text;
using System.Collections.Generic;
using System.Linq;
using System.Reflection.Metadata.Ecma335;
using System.Text;
using System.Threading.Tasks;

namespace eBiblioteka.Modeli.SearchObjects
{
    public class TerminSearchObject:BaseSearchObject
    {
        public DateOnly? DatumGTE { get; set; }

        public DateOnly? DatumLTE { get; set; }

        public bool? JeRezervisan { get; set; }

        public int? CitaonicaId { get; set; }

        public string? ImePrezimeGTE { get; set; }
    }
}
