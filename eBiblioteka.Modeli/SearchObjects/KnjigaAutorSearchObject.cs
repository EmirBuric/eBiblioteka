using System;
using System.Collections.Generic;
using System.Text;

namespace eBiblioteka.Modeli.SearchObjects
{
    public class KnjigaAutorSearchObject: BaseSearchObject
    {
        public int? AutorId { get; set; }

        public int? KnjigaId { get; set; }
    }
}
