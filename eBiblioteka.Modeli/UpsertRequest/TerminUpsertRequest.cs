using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBiblioteka.Modeli.UpsertRequest
{
    public class TerminUpsertRequest
    {
        public DateOnly Datum { get; set; }

        public TimeOnly Start { get; set; }

        public TimeOnly Kraj { get; set; }

        public int CitaonicaId { get; set; }
    }
}
