using System;
using System.Collections.Generic;

namespace eBiblioteka.Servisi.Database;

public partial class TipClanarine
{
    public int TipClanarineId { get; set; }

    public int VrijemeTrajanja { get; set; }

    public int Cijena { get; set; }

    public virtual ICollection<Clanarina> Clanarinas { get; set; } = new List<Clanarina>();
}
