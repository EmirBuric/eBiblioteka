using System;
using System.Collections.Generic;

namespace eBiblioteka.Servisi.Database;

public partial class Citaonica
{
    public int CitaonicaId { get; set; }

    public string Naziv { get; set; } = null!;

    public virtual ICollection<Termin> Termins { get; set; } = new List<Termin>();
}
