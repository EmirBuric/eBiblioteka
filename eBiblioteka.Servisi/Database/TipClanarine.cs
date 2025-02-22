using System;
using System.Collections.Generic;

namespace eBiblioteka.Servisi.Database;

public partial class TipClanarine
{
    public int TipClanarineId { get; set; }

    public string VrijemeTrajanja { get; set; } = null!;

    public virtual ICollection<Clanarina> Clanarinas { get; set; } = new List<Clanarina>();
}
