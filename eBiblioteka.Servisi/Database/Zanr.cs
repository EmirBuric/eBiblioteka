using System;
using System.Collections.Generic;

namespace eBiblioteka.Servisi.Database;

public partial class Zanr
{
    public int ZanrId { get; set; }

    public string Naziv { get; set; } = null!;

    public virtual ICollection<Knjiga> Knjigas { get; set; } = new List<Knjiga>();
}
