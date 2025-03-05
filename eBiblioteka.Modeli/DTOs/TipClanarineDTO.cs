using System;
using System.Collections.Generic;
using System.Text;

namespace eBiblioteka.Modeli.DTOs
{
    public class TipClanarineDTO
    {
        public int TipClanarineId { get; set; }

        public int VrijemeTrajanja { get; set; }
        
        public int Cijena { get; set; } 

        //public virtual ICollection<Clanarina> Clanarinas { get; set; } = new List<Clanarina>();
    }
}
